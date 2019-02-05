/******************************************************************************
 *
 *       Copyright Zebra Technologies Corporation. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:   ConnectionManager.m
 *
 *  Notes: Manages connections to Zebra scanners
 *
 ******************************************************************************/

#import "ConnectionManager.h"
#import "ScannerAppEngine.h"



@interface ConnectionManager ()
{
    int scannerIdToConnect;
}

@property (nonatomic,retain) SbtScannerInfo *connectedScanner;

@end

@implementation ConnectionManager

#pragma mark Singleton methods

static ConnectionManager *sharedConnectionManager = nil;

+ (ConnectionManager *) sharedConnectionManager
{
    @synchronized([ConnectionManager class])
    {
        if (sharedConnectionManager == nil)
        {
            [[self alloc] init];
        }
        
        return sharedConnectionManager;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([ConnectionManager class])
    {
        NSAssert(sharedConnectionManager == nil, @"Attempted to allocate a second instance of the connection manager singleton.");
        sharedConnectionManager = [super alloc];
        return sharedConnectionManager;
    }
    
    return nil;
}

+(void)destroy
{
    @synchronized([ConnectionManager class])
    {
        // deallocate here
    }
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        [self initializeConnectionManager];
    }
    
    return self;
}



- (void) initializeConnectionManager
{
    self.connectedScanner = nil;
    
    // Register for scanner events
    [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
}

// establish connection to the device (scanner and rfid sdk) using the scanner id
- (void)connectDeviceUsingScannerId:(int)scannerId
{
    // Are we attempting to connect to a different scanner than the one that is already connected?
    if ([self.connectedScanner isActive] && scannerId != [self.connectedScanner getScannerID])
    {
        // Yes, so disconnect from the previously connected scanner
        [self disconnect];
    }
    
    // Establish connection with the new scanner
    [[zt_ScannerAppEngine sharedAppEngine] connect:scannerId];
}

// disconnect from both the scanner and rfid sdk using the scanner id
- (void) disconnect
{
    [[zt_ScannerAppEngine sharedAppEngine] disconnect:[self.connectedScanner getScannerID]];
}


- (int) getConnectedScannerId
{
    return [self.connectedScanner getScannerID];
}

- (BOOL) isConnected
{
    return [self.connectedScanner isActive];
}

#pragma IScannerAppEngineDevConnectionsDelegate

- (BOOL)scannerHasAppeared:(int)scannerID
{
    // do not handle this event
    return FALSE;
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    // do not handle this event
    return FALSE;
}

-(BOOL)scannerHasConnected:(int)scannerID
{
    scannerIdToConnect = scannerID;
    
    // Is there a different scanner that is already connected?
    if ([self isConnected] && [self.connectedScanner getScannerID] != scannerID)
    {
        // Yes, so disconnect from this scanner first before connecting to the new scanner
        [self disconnect];
    }
    else
    {
        // No, set as the new connected scanner
        self.connectedScanner = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
    }
    
    return TRUE;
}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    self.connectedScanner = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerIdToConnect];
    

    return TRUE;
}


@end
