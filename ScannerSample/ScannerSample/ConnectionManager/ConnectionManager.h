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
 *  Description:   ConnectionManager.h
 *
 *  Notes: Manages connections to Zebra scanners
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "ScannerAppEngine.h"

@interface ConnectionManager : NSObject <IScannerAppEngineDevConnectionsDelegate>

+ (ConnectionManager *) sharedConnectionManager;

- (void) initializeConnectionManager;

// establish connection to the scanner sdk
- (void)connectDeviceUsingScannerId:(int)scannerId;

// disconnect from the scanner sdk
- (void) disconnect;

// get connected scanner id
- (int) getConnectedScannerId;

// are we connected?
- (BOOL) isConnected;

@end
