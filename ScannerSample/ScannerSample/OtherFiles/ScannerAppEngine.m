/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ScannerAppEngine.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ScannerAppEngine.h"
#import "SbtSdkFactory.h"
#import "AppSettingsKeys.h"
#import "BarcodeTypes.h"
#import "config.h"
#import "DecodeEvent.h"
#import "BarcodeList.h"
#import "ConnectionManager.h"
#import "RMDAttributes.h"
#import "ScannerSample-Bridging-Header.h"
#import "ScannerSample-Swift.h"

#define ZT_NOTIFICATION_KEY_SCANNER_ID         @"SbtNotificationKeyScannerId"
#define ZT_NOTIFICATION_KEY_BARCODE            @"SbtNotificationKeyBarcode"

// When the flags below is defined, in-app popups that indicate
// scanner appearance/disappearance/connection/disconnection are suppressed
#define SUPPRESS_IN_APP_APPEARANCE_ALERT       1
#define SUPPRESS_IN_APP_DISAPPEARANCE_ALERT    1
//#define SUPPRESS_IN_APP_CONNECTION_ALERT       1
//#define SUPPRESS_IN_APP_DISCONNECTION_ALERT    1

@interface zt_ScannerAppEngine()
{
    BOOL didFWUpdate;
    int previousScanner;
}

@property (atomic,retain) UIAlertView *m_lastAlertView;

@end
@implementation zt_ScannerAppEngine

zt_ScannerAppEngine *_g_sharedAppEngine = nil;

+ (zt_ScannerAppEngine *) sharedAppEngine
{
    @synchronized([zt_ScannerAppEngine class])
    {
        if (_g_sharedAppEngine == nil)
        {
            [[self alloc] init];
        }
        
        return _g_sharedAppEngine;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([zt_ScannerAppEngine class])
    {
        NSAssert(_g_sharedAppEngine == nil, @"Attempted to allocate a second instance of a singleton.");
        _g_sharedAppEngine = [super alloc];
        return _g_sharedAppEngine;
    }
    
    return nil;
}

+(void)destroy
{
    @synchronized([zt_ScannerAppEngine class])
    {
        if (_g_sharedAppEngine != nil)
        {
            [_g_sharedAppEngine dealloc];
        }
    }
}

-(id)init
{
	self = [super init];
	if (self != nil)
    {
        m_ScannerInfoList = [[NSMutableArray alloc] init];
        m_DevListDelegates = [[NSMutableArray alloc] init];
        m_DevConnectionsDelegates = [[NSMutableArray alloc] init];
        m_DevEventsDelegates = [[NSMutableArray alloc] init];
        m_ScannerBarcodeList = [[NSMutableArray alloc] init];
        m_UINotificationList = [[NSMutableArray alloc] init];
        m_FWUpdateProgressDelegateList = [[NSMutableArray alloc] init];
        
        m_ScannerInfoListGuard = [[NSLock alloc] init];
        
        self.m_lastAlertView = [[UIAlertView alloc] init];
        
        [self initializeDcsSdkWithAppSettings];
	}
    
	return self;
}

- (void)dealloc
{
    /* release all allocated for singleton objects */
    if (m_ScannerInfoList != nil)
    {
        [m_ScannerInfoList removeAllObjects];
        [m_ScannerInfoList release];
    }
    if (m_DevListDelegates != nil)
    {
        [m_DevListDelegates removeAllObjects];
        [m_DevListDelegates release];
    }
    if (m_DevConnectionsDelegates != nil)
    {
        [m_DevConnectionsDelegates removeAllObjects];
        [m_DevConnectionsDelegates release];
    }
    if (m_DevEventsDelegates != nil)
    {
        [m_DevEventsDelegates removeAllObjects];
        [m_DevEventsDelegates release];
    }
    if (m_ScannerBarcodeList != nil)
    {
        [m_ScannerBarcodeList removeAllObjects];
        [m_ScannerBarcodeList release];
    }
    if (m_UINotificationList != nil)
    {
        [m_UINotificationList removeAllObjects];
        [m_UINotificationList release];
    }
    if (m_ScannerInfoListGuard != nil)
    {
        [m_ScannerInfoListGuard release];
    }
    if (self.m_lastAlertView != nil)
    {
        [self.m_lastAlertView release];
    }
    if (m_FWUpdateProgressDelegateList != nil) {
        [m_FWUpdateProgressDelegateList removeAllObjects];
        [m_FWUpdateProgressDelegateList release];
    }

    [super dealloc];
}

- (void)initializeDcsSdkWithAppSettings
{
    m_DcsSdkApi = [SbtSdkFactory createSbtSdkApiInstance];
    [m_DcsSdkApi sbtSetDelegate:self];
    

    NSLog(@"SBT SDK version: %@", [m_DcsSdkApi sbtGetVersion]);
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    /* 
     NSUserDefaults returns 0 for number if the key doesn't exist
     Check that 0 is not a valid value for the parameter

    */
    
    int op_mode = (int)[settings integerForKey:ZT_SETTING_OPMODE];
    if (op_mode == 0)
    {
        /* no value => setup default values */
        /***
         Changed the default opmode all
         */
        op_mode = SBT_OPMODE_ALL;
        [settings setInteger:op_mode forKey:ZT_SETTING_OPMODE];
        [settings setBool:YES forKey:ZT_SETTING_SCANNER_DETECTION];
        [settings setBool:YES forKey:ZT_SETTING_EVENT_ACTIVE];
        [settings setBool:YES forKey:ZT_SETTING_EVENT_AVAILABLE];
        [settings setBool:YES forKey:ZT_SETTING_EVENT_BARCODE];
        [settings setBool:YES forKey:ZT_SETTING_EVENT_IMAGE];
        [settings setBool:YES forKey:ZT_SETTING_EVENT_VIDEO];
        
        [settings setBool:YES forKey:ZT_SETTING_NOTIFICATION_ACTIVE];
        [settings setBool:YES forKey:ZT_SETTING_NOTIFICATION_AVAILABLE];
        [settings setBool:NO forKey:ZT_SETTING_NOTIFICATION_BARCODE];
        [settings setBool:NO forKey:ZT_SETTING_NOTIFICATION_IMAGE];
        [settings setBool:NO forKey:ZT_SETTING_NOTIFICATION_VIDEO];
    }
    
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    /*  nrv364: we have removed SDK subcribtion control from app UI
        let's always override app settings related to SDK events to enable
        all events
        note: the functionality is required only for the first build with 
        said mentioned changes because in case of app re-installation without
        deinstallation we could NOT ensure that our default values 
        will be configured due to available settings from previous app version
     */
    [settings setBool:YES forKey:ZT_SETTING_EVENT_ACTIVE];
    [settings setBool:YES forKey:ZT_SETTING_EVENT_AVAILABLE];
    [settings setBool:YES forKey:ZT_SETTING_EVENT_BARCODE];
    [settings setBool:YES forKey:ZT_SETTING_EVENT_IMAGE];
    [settings setBool:YES forKey:ZT_SETTING_EVENT_VIDEO];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    
    BOOL scanner_detection = [settings boolForKey:ZT_SETTING_SCANNER_DETECTION];
    int notifications_mask = 0;
    if ([settings boolForKey:ZT_SETTING_EVENT_AVAILABLE] == YES)
    {
        notifications_mask |= (SBT_EVENT_SCANNER_APPEARANCE | SBT_EVENT_SCANNER_DISAPPEARANCE);
    }
    if ([settings boolForKey:ZT_SETTING_EVENT_ACTIVE] == YES)
    {
        notifications_mask |= (SBT_EVENT_SESSION_ESTABLISHMENT | SBT_EVENT_SESSION_TERMINATION);
    }
    if ([settings boolForKey:ZT_SETTING_EVENT_BARCODE] == YES)
    {
        notifications_mask |= (SBT_EVENT_BARCODE);
    }
    if ([settings boolForKey:ZT_SETTING_EVENT_IMAGE] == YES)
    {
        notifications_mask |= (SBT_EVENT_IMAGE);
    }
    if ([settings boolForKey:ZT_SETTING_EVENT_VIDEO] == YES)
    {
        notifications_mask |= (SBT_EVENT_VIDEO);
    }
    
    /* 
     TBD:
        it doesn't matter in which order enable scanner detection and set op mode:
            - when scanner detection becomes enabled, corresponding discover
                procedure is performed;
            - when opmode becomes enabled, if scanner detection is already enabled,
                corresponding discover procedure is performed (moreover, when some
                opmode becomes disabled, all incompatible scanners are removed from
                available/active lists independently on detection option status)
     Update SRS?
            Because enabling of op mode as well as enabling of detection options 
        immidiately results in discover procedure, the app SHALL be already suscribed for
        corresponding notifications.
     */
    [m_DcsSdkApi sbtSetOperationalMode:op_mode];
    [m_DcsSdkApi sbtSubsribeForEvents:notifications_mask];
    [m_DcsSdkApi sbtEnableAvailableScannersDetection:scanner_detection];
    
}

/* ###################################################################### */
/* ########## Utility functions ######################################### */
/* ###################################################################### */

- (void)showMessageBox:(NSString*)message
{
    // if there is already a message box displayed, then dismiss it automatically
    if (self.m_lastAlertView.visible)
    {
        [self.m_lastAlertView dismissWithClickedButtonIndex:0 animated:NO];

        self.m_lastAlertView = nil;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:ZT_SCANNER_APP_NAME
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    self.m_lastAlertView = alert;

    [alert show];
    [alert release];
}

- (int)showBackgroundNotification:(NSString *)text aDictionary:(NSDictionary*)param_dict
{
    /* there is no need for notification when we are in foreground */
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        UILocalNotification * notif = [[UILocalNotification alloc] init];
        if (notif)
        {
            notif.repeatInterval = 0;
            notif.alertBody = text;
            notif.soundName = UILocalNotificationDefaultSoundName;
            notif.alertAction = ZT_SCANNER_APP_NAME;
            notif.userInfo = param_dict;
            [m_UINotificationList addObject:notif];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
            [notif release];
        }
    }
    return 0;
}

- (int)processBackroundNotification:(UILocalNotification*)notification
{
    NSDictionary *params = [notification userInfo];
    
    NSNumber *param = (NSNumber*)[params objectForKey:ZT_NOTIFICATION_KEY_SCANNER_ID];
    
    if (param == nil)
    {
        return 0;
    }
    
    int scanner_id = [param intValue];
    
    param = (NSNumber*)[params objectForKey:ZT_NOTIFICATION_KEY_BARCODE];
    
    BOOL barcode = (param != nil);

    /* cancell all notification related to this scanner */
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    [m_UINotificationList removeObject:notification];
    NSMutableArray *tmp_delete = [[NSMutableArray alloc] init];
    for (UILocalNotification *notif in [[m_UINotificationList copy] autorelease])
    {
        params = [notif userInfo];
        param = (NSNumber*)[params objectForKey:ZT_NOTIFICATION_KEY_SCANNER_ID];
        if ((param != nil) && ([param intValue] == scanner_id))
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notif];
            [tmp_delete addObject:notif];
        }
    }
    for (UILocalNotification *notif in tmp_delete)
    {
        [m_UINotificationList removeObject:notif];
    }
    [tmp_delete removeAllObjects];
    [tmp_delete release];
    
    /* nrv364: 
     currently we have only one DevEventsDelegate (ZT_ScannerAppVC) which shall
     show the appropriate UI for received notification
     probably separate delegate/protocol shall be defined for notification processing
    */
    for (id<IScannerAppEngineDevEventsDelegate> delegate in [[m_DevEventsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            [delegate showScannerRelatedUI:scanner_id barcodeNotification:barcode];
        }
    }
    
    return 0;
}

- (int)dismissBackgroundNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    return 0;
}

- (BOOL)isInBackgroundMode
{
    /* TBD: decide if background mode is:
     - !(UIApplicationStateActive) = UIApplicationStateInactive OR UIApplicationStateBackground
     - UIApplicationstateBackground
     */
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
    {
        return YES;
    }
    return NO;
}

- (void)fillScannersList:(NSMutableArray**)list
{
    NSMutableArray *available = [[NSMutableArray alloc] init];
    NSMutableArray *active = [[NSMutableArray alloc] init];
    
    if (m_DcsSdkApi != nil)
    {
        if ([m_DcsSdkApi sbtGetAvailableScannersList:&available] == SBT_RESULT_FAILURE)
        {
            dispatch_async(dispatch_get_main_queue(),
                ^{
                    [self showMessageBox:@"Search for available scanners has failed"];
                }
            );
        }
        [m_DcsSdkApi sbtGetActiveScannersList:&active];
        
        /* nrv364: due to auto-reconnect option some available scanners may have 
         changed to active and thus the same scanner has appeared in two lists */
        for (SbtScannerInfo *act in active)
        {
            for (SbtScannerInfo *av in available)
            {
                if ([av getScannerID] == [act getScannerID])
                {
                    [available removeObject:av];
                    break;
                }
            }
        }
        if ((list != nil) && (*list != nil))
        {
            [*list removeAllObjects];
            [*list addObjectsFromArray:available];
            [*list addObjectsFromArray:active];
        }
    }
    
    [available release];
    [active release];
}

- (NSString*)getScannerModelName:(int)scannerModel
{
    switch (scannerModel)
    {
        case SBT_DEVMODEL_INVALID:
            return SST_SCANNER_MODEL_UNKNOWN;
        case SBT_DEVMODEL_RFID_RFD8500:
            return SST_SCANNER_MODEL_RFID_RFD8500;
        case SBT_DEVMODEL_SSI_CS4070:
            return SST_SCANNER_MODEL_SSI_CS4070;
        case SBT_DEVMODEL_SSI_GENERIC:
            return SST_SCANNER_MODEL_SSI_GENERIC;
        case SBT_DEVMODEL_SSI_RFD8500:
            return SST_SCANNER_MODEL_SSI_RFD8500;
        case SBT_DEVMODEL_SSI_LI3678:
            return SST_SCANNER_MODEL_SSI_LI3678;
        case SBT_DEVMODEL_SSI_DS3678:
            return SST_SCANNER_MODEL_SSI_DS3678;
        case SBT_DEVMODEL_SSI_DS8178:
            return SST_SCANNER_MODEL_SSI_DS8178;
        case SBT_DEVMODEL_SSI_DS2278:
            return SST_SCANNER_MODEL_SSI_DS2278;
    }
    return SST_SCANNER_MODEL_UNKNOWN;
}

/* ###################################################################### */
/* ########## API calls for UI View Controllers ######################### */
/* ###################################################################### */
- (void)addDevListDelegate:(id<IScannerAppEngineDevListDelegate>)delegate
{
    [m_DevListDelegates addObject:delegate];
}

- (void)addDevConnectionsDelegate:(id<IScannerAppEngineDevConnectionsDelegate>)delegate
{
    [m_DevConnectionsDelegates addObject:delegate];
}

- (void)addDevEventsDelegate:(id<IScannerAppEngineDevEventsDelegate>)delegate
{
    [m_DevEventsDelegates addObject:delegate];
}

- (void)addFWUpdateEventsDelegate:(id<IScannerAppEngineFWUpdateEventsDelegate>)delegate
{
    [m_FWUpdateProgressDelegateList addObject:delegate];
}

- (void)removeFWUpdateEventsDelegate:(id<IScannerAppEngineFWUpdateEventsDelegate>)delegate
{
    [m_FWUpdateProgressDelegateList removeObject:delegate];
}

- (void)removeDevListDelegate:(id<IScannerAppEngineDevListDelegate>)delegate
{
    [m_DevListDelegates removeObject:delegate];
}

- (void)removeDevConnectiosDelegate:(id<IScannerAppEngineDevConnectionsDelegate>)delegate
{
    [m_DevConnectionsDelegates removeObject:delegate];
}

- (void)removeDevEventsDelegate:(id<IScannerAppEngineDevEventsDelegate>)delegate;
{
    [m_DevEventsDelegates removeObject:delegate];
}

- (NSArray*)getCompleteScannersList
{
    return m_ScannerInfoList;
}

- (NSArray*)getAvailableScannersList
{
    NSMutableArray *availableScanners = [[[NSMutableArray alloc] init] autorelease];
    
    for (SbtScannerInfo *info in [[m_ScannerInfoList copy] autorelease])
    {
        if ([info isAvailable])
        {
            [availableScanners addObject:info];
        }
    }
    
    return availableScanners;
}

- (SbtScannerInfo*)getScannerInfoByIdx:(int)dev_index
{
    return (SbtScannerInfo*)[m_ScannerInfoList objectAtIndex:dev_index];
}

- (SbtScannerInfo*)getScannerByID:(int)scanner_id
{
    for (SbtScannerInfo* info in [[m_ScannerInfoList copy] autorelease])
    {
        if ([info getScannerID] == scanner_id)
        {
            return info;
        }
    }
    return nil;
}

- (void)raiseDeviceNotificationsIfNeeded
{
    /*
        nrv364: 
        - not used in the application as Active/Available events are
     always on
        - if Active/Available events will be enabled (see
            SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG) then access to
            m_ScannerInfoList shall be synchronized with m_ScannerInfoListGuard
    */
    
    /*
     - When [Detection] option is enabled and [Available/Active] events are
     disabled the SDK updates its internal dev list in real time but does
     NOT inform app/subsriber about it => app list is NOT up to date
     - When [Detection] option is enabled and [Available/Active] events are
     disabled the user is able to update app dev list via [Update] button
     - If we will enable [Available/Active] events, then:
        - [Update] button will disappear
        - App dev list is still NOT up to date because, SDK enabling 
        [Available/Active] events in SDK will result in sending corresponding
        notifications from SDK only when actual events are detected (therefore
        notifications from previous events will not be raised)
        - To update the app dev list and raise corresponding UI notifications, 
        the app should get actual dev list from SDK and compare it with 
        current app dev list
     */
    
    NSMutableArray *_dev_list = [[NSMutableArray alloc] init];
    
    if (m_DcsSdkApi != nil)
    {
        [self fillScannersList:&(_dev_list)];
        
        BOOL dev_found = NO;
        
        /* compare NEW dev list with OLD dev list */
        /* find active/available changes */
        /* find appearance */
        for (SbtScannerInfo *new_dev in _dev_list)
        {
            dev_found = NO;
            for (SbtScannerInfo *old_dev in [[m_ScannerInfoList copy] autorelease])
            {
                if ([new_dev getScannerID] == [old_dev getScannerID])
                {
                    dev_found = YES;
                    
                    /* new dev is in the list -> check changes in active status */
                    
                    if (([new_dev isActive] == YES) && ([old_dev isActive] == NO))
                    {
                        if (YES == [[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE])
                        {
                            [self sbtEventCommunicationSessionEstablished:new_dev];
                        }
                    }
                    else if (([new_dev isActive] == NO) && ([old_dev isActive] == YES))
                    {
                        if (YES == [[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE])
                        {
                            [self sbtEventCommunicationSessionTerminated:[new_dev getScannerID]];
                        }
                    }
                    break;
                }
            }
            if (NO == dev_found)
            {
                /* new dev is not in the list -> raise appearance notification */
                if (YES == [[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_AVAILABLE])
                {
                    [self sbtEventScannerAppeared:new_dev];
                }
                if ([new_dev isActive] == YES)
                {
                    if (YES == [[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE])
                    {
                        [self sbtEventCommunicationSessionEstablished:new_dev];
                    }
                }
            }
        }
        
        /* compare OLD dev list with NEW dev list */
        /* find disappearance */
        for (SbtScannerInfo *old_dev in [[m_ScannerInfoList copy] autorelease])
        {
            dev_found = NO;
            for (SbtScannerInfo *new_dev in _dev_list)
            {
                if ([new_dev getScannerID] == [old_dev getScannerID])
                {
                    /* dev is in both lists -> was processed before */
                    dev_found = YES;
                    break;
                }
            }
            if (NO == dev_found)
            {
                /* old dev is not in the new list -> raise disappearance notification */
                if ([old_dev isActive] == YES)
                {
                    if (YES == [[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE])
                    {
                        [self sbtEventCommunicationSessionTerminated:[old_dev getScannerID]];
                    }
                }
                if (YES == [[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_AVAILABLE])
                {
                    [self sbtEventScannerDisappeared:[old_dev getScannerID]];
                }
            }
        }
    }
    
    [_dev_list removeAllObjects];
    [_dev_list release];
}

- (NSArray*)getScannerBarcodesByID:(int)scanner_id
{
    /* find barcode list for specified scanner */
    
    for (zt_BarcodeList *barcode_lst in [[m_ScannerBarcodeList copy] autorelease])
    {
        if (scanner_id == [barcode_lst getScannerID])
        {
            return [barcode_lst getBarcodeList];
        }
    }
    
    return nil;
}

- (void)clearScannerBarcodesByID:(int)scanner_id
{
    /* find barcode list for specified scanner */
    
    for (zt_BarcodeList *barcode_lst in [[m_ScannerBarcodeList copy] autorelease])
    {
        if (scanner_id == [barcode_lst getScannerID])
        {
            [barcode_lst clearBarcodeList];
        }
    }
}

/* ###################################################################### */
/* ########## Interface for DCS SDK ##################################### */
/* ###################################################################### */

- (void)updateScannersList
{
    if (m_DcsSdkApi != nil)
    {
        if (YES == m_BusyScannerAction)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageBox:@"Search for available scanners has failed"];
            });
            return;
        }
        
        if (YES == [m_ScannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
        {
            [m_ScannerInfoList removeAllObjects];
            [self fillScannersList:&(m_ScannerInfoList)];
            
            /* update barcode list array accordingly */
            /* remove barcode lists not active scanners (including both available and disappeared) */
            BOOL active_found;
            for (zt_BarcodeList *barcode_lst in [[m_ScannerBarcodeList copy] autorelease])
            {
                active_found = NO;
                for (SbtScannerInfo *scanner_info in [[m_ScannerInfoList copy] autorelease])
                {
                    if ([scanner_info getScannerID] == [barcode_lst getScannerID])
                    {
                        if (YES == [scanner_info isActive])
                        {
                            active_found = YES;
                            break;
                        }
                    }
                }
                
                if (NO == active_found)
                {
                    [m_ScannerBarcodeList removeObject:barcode_lst];
                }
            }
            
            /* add barcode lists for active scanners */
            for (SbtScannerInfo *scanner_info in [[m_ScannerInfoList copy] autorelease])
            {
                if (YES == [scanner_info isActive])
                {
                    active_found = NO;
                    for (zt_BarcodeList *barcode_lst in [[m_ScannerBarcodeList copy] autorelease])
                    {
                        if ([barcode_lst getScannerID] == [scanner_info getScannerID])
                        {
                            /* barcode list for active scanner already exists */
                            active_found = YES;
                        }
                    }
                    
                    if (NO == active_found)
                    {
                        zt_BarcodeList* new_barcode_lst = [[zt_BarcodeList alloc] initWithMotoID:[scanner_info getScannerID] andName:[scanner_info getScannerName]];
                        [m_ScannerBarcodeList addObject:new_barcode_lst];
                        [new_barcode_lst release];
                    }
                }
            }
            
            [m_ScannerInfoListGuard unlock];
        }

        /* notify delegates */
        for (id<IScannerAppEngineDevListDelegate> delegate in [[m_DevListDelegates copy] autorelease])
        {
            if (delegate != nil)
            {
                /* TBD: appear/disappear, connect/disconnect logic ? */
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate scannersListHasBeenUpdated];
                });
            }
        }
    }
}

- (void)connect:(int)scanner_id
{
    if (m_DcsSdkApi != nil)
    {
        m_BusyScannerAction = TRUE;
        SBT_RESULT conn_result = [m_DcsSdkApi sbtEstablishCommunicationSession:scanner_id];
        m_BusyScannerAction = FALSE;
        if (SBT_RESULT_SUCCESS != conn_result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageBox:@"Connection failed"];
            });
        }
        else
        {
            // Connection established successfully.
            
            // Reset auto reconnect to false for all scanners and set true for connected scanner.
            
            [self setAutoReconnectOptionAfterScannerConnected:scanner_id];
        }
    }
}

-(void)setAutoReconnectOptionAfterScannerConnected:(int)scanner_id
{
    SBT_RESULT result = NO;
    // Reset auto reconnect to false for all scanners.
    //
    NSArray *scannersList = [self getCompleteScannersList];
    
    for (SbtScannerInfo *info in scannersList)
    {
        result = [self setAutoReconnectOption:[info getScannerID] enableOption:NO];
    }
    
    // Set auto reconnect for the recently connected scanner to true.
    //
    result = [self setAutoReconnectOption:scanner_id enableOption:YES];
}

- (void)disconnect:(int)scanner_id
{
    SBT_RESULT result = NO;
    if (m_DcsSdkApi != nil)
    {
        m_BusyScannerAction = TRUE;
        SBT_RESULT res = [m_DcsSdkApi sbtTerminateCommunicationSession:scanner_id];
        if (res == SBT_RESULT_FAILURE) {
            [self showMessageBox:@"Failed to disconnect. Please try again later"];
        }
        else
        {
            // Graceful disconnection - Only reconnect to scanners that
            // disconnected unexpectedly. Disable auto reconnect for
            // this device since it disconnected expectedly.
            result = [self setAutoReconnectOption:scanner_id enableOption:NO];
        }
        
        m_BusyScannerAction = FALSE;
    }
}

- (SBT_RESULT)setAutoReconnectOption:(int)scanner_id enableOption:(BOOL)enable
{
    SBT_RESULT result = NO;
    if (m_DcsSdkApi != nil)
    {
        result = [m_DcsSdkApi sbtEnableAutomaticSessionReestablishment:enable forScanner:scanner_id];
        if (result == SBT_RESULT_SUCCESS) {
            if (YES == [m_ScannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
            {
                for (SbtScannerInfo *ex_info in [[m_ScannerInfoList copy] autorelease])
                {
                    if ([ex_info getScannerID] == scanner_id)
                    {
                        /* find scanner with ID in dev list */
                        [ex_info setAutoCommunicationSessionReestablishment:enable];
                        break;
                    }
                }
                [m_ScannerInfoListGuard unlock];
            }

        }
    }
    return result;
}

- (void)enableScannersDetection:(BOOL)enable
{
    if (m_DcsSdkApi != nil)
    {
        [m_DcsSdkApi sbtEnableAvailableScannersDetection:enable];
    }
}

- (void)configureNotificationAvailable:(BOOL)enable
{
    if (m_DcsSdkApi != nil)
    {
        if (enable)
        {
            [m_DcsSdkApi sbtSubsribeForEvents:(SBT_EVENT_SCANNER_APPEARANCE | SBT_EVENT_SCANNER_DISAPPEARANCE)];
        }
        else
        {
            [m_DcsSdkApi sbtUnsubsribeForEvents:(SBT_EVENT_SCANNER_APPEARANCE | SBT_EVENT_SCANNER_DISAPPEARANCE)];
        }
    }
}

- (void)configureNotificationActive:(BOOL)enable
{
    if (m_DcsSdkApi != nil)
    {
        if (enable)
        {
            [m_DcsSdkApi sbtSubsribeForEvents:(SBT_EVENT_SESSION_ESTABLISHMENT | SBT_EVENT_SESSION_TERMINATION)];
        }
        else
        {
            [m_DcsSdkApi sbtUnsubsribeForEvents:(SBT_EVENT_SESSION_ESTABLISHMENT | SBT_EVENT_SESSION_TERMINATION)];
        }
    }
}

- (void)configureNotificationBarcode:(BOOL)enable
{
    if (m_DcsSdkApi != nil)
    {
        if (enable)
        {
            [m_DcsSdkApi sbtSubsribeForEvents:SBT_EVENT_BARCODE];
        }
        else
        {
            [m_DcsSdkApi sbtUnsubsribeForEvents:SBT_EVENT_BARCODE];
        }
    }
}

- (void)configureNotificationImage:(BOOL)enable
{
    if (m_DcsSdkApi != nil)
    {
        if (enable)
        {
            [m_DcsSdkApi sbtSubsribeForEvents:SBT_EVENT_IMAGE];
        }
        else
        {
            [m_DcsSdkApi sbtUnsubsribeForEvents:SBT_EVENT_IMAGE];
        }
    }
}

- (void)configureNotificationVideo:(BOOL)enable
{
    if (m_DcsSdkApi != nil)
    {
        if (enable)
        {
            [m_DcsSdkApi sbtSubsribeForEvents:SBT_EVENT_VIDEO];
        }
        else
        {
            [m_DcsSdkApi sbtUnsubsribeForEvents:SBT_EVENT_VIDEO];
        }
    }
}

- (void)configureOperationalMode:(int)mode
{
    if (m_DcsSdkApi != nil)
    {
        [m_DcsSdkApi sbtSetOperationalMode:mode];
    }
}

- (SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML aOutXML:(NSMutableString**)outXML forScanner:(int)scannerID
{
    if (m_DcsSdkApi != nil)
    {
        return [m_DcsSdkApi sbtExecuteCommand:opCode aInXML:inXML aOutXML:outXML forScanner:scannerID];
    }
    return SBT_RESULT_FAILURE;
}

- (SBT_RESULT)beepControl:(int)beepCode forScanner:(int)scannerID
{
    if (m_DcsSdkApi != nil)
    {
        return [m_DcsSdkApi sbtBeepControl:beepCode forScanner:scannerID];
    }
    return SBT_RESULT_FAILURE;
}

- (SBT_RESULT)ledControl:(BOOL)enable aLedCode:(int)ledCode forScanner:(int)scannerID
{
    if (m_DcsSdkApi != nil)
    {
        return [m_DcsSdkApi sbtLedControl:enable aLedCode:ledCode forScanner:scannerID];
    }
    return SBT_RESULT_FAILURE;
}

- (void)setBluetoothAddress:(NSString*)blAddress
{
    if (m_DcsSdkApi != nil)
    {
        [m_DcsSdkApi sbtSetBTAddress:blAddress];
    }
}

- (NSString*)getSDKVersion
{
    return [m_DcsSdkApi sbtGetVersion];
}

- (UIImage*) sbtSTCPairingBarcode:(BARCODE_TYPE)barcodeType withComProtocol:(STC_COM_PROTOCOL)comProtocol withSetDefaultStatus:(SETDEFAULT_STATUS)setDefaultsStatus withBTAddress:(NSString*)btAddress withImageFrame:(CGRect)imageFrame
{
    return [m_DcsSdkApi sbtGetPairingBarcode:barcodeType withComProtocol:comProtocol withSetDefaultStatus:setDefaultsStatus withBTAddress:btAddress withImageFrame:imageFrame];
}

/* ###################################################################### */
/* ########## IDcsSdkApiDelegate Protocol implementation ################ */
/* ###################################################################### */

- (void)sbtEventScannerAppeared:(SbtScannerInfo*)availableScanner
{
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    
    /* update dev list */
    BOOL found = NO;
    
    if (YES == [m_ScannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (SbtScannerInfo *ex_info in [[m_ScannerInfoList copy] autorelease])
        {
            if ([ex_info getScannerID] == [availableScanner getScannerID])
            {
                /* find scanner with ID in dev list */
                [ex_info setActive:NO];
                [ex_info setAvailable:YES];
                [ex_info setAutoCommunicationSessionReestablishment:[availableScanner getAutoCommunicationSessionReestablishment]];
                [ex_info setConnectionType:[availableScanner getConnectionType]];
                found = YES;
                break;
            }
        }
        
        if (found == NO)
        {
            SbtScannerInfo *scanner_info = [[SbtScannerInfo alloc] init];
            [scanner_info setActive:NO];
            [scanner_info setAvailable:YES];
            [scanner_info setScannerID:[availableScanner getScannerID]];
            [scanner_info setAutoCommunicationSessionReestablishment:[availableScanner getAutoCommunicationSessionReestablishment]];
            [scanner_info setConnectionType:[availableScanner getConnectionType]];
            [scanner_info setScannerName:[availableScanner getScannerName]];
            [scanner_info setScannerModel:[availableScanner getScannerModel]];
            [m_ScannerInfoList addObject:scanner_info];
            [scanner_info release];
        }
        
        [m_ScannerInfoListGuard unlock];
    }
    
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether available notifications are enabled */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_AVAILABLE] == YES)
        {
            NSString *notif_str = [NSString stringWithFormat:@"%@ has appeared", [availableScanner getScannerName]];
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[availableScanner getScannerID]] forKey:ZT_NOTIFICATION_KEY_SCANNER_ID];
            [self showBackgroundNotification:notif_str aDictionary:notif_dict];
        }
    }


    /* notify connections delegates */
    for (id<IScannerAppEngineDevConnectionsDelegate> delegate in [[m_DevConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            result = [delegate scannerHasAppeared:[availableScanner getScannerID]];
            if (result == YES)
            {
                /*
                 DevConnections delegates should NOT display any UI alerts,
                 so from UI notification side the event is not processed
                 */
                notificaton_processed = NO;
            }
            
        }
    }
    
    /* notify dev list delegates */
    for (id<IScannerAppEngineDevListDelegate> delegate in [[m_DevListDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            result = [delegate scannersListHasBeenUpdated];
            if (result == YES)
            {
                /*
                 DeList delegates should NOT display any UI alerts,
                 so from UI notification side the event is not processed
                 */

                notificaton_processed = NO;
            }
        }
    }
    
    if ([self isInBackgroundMode] == NO)
    {
        if (NO == notificaton_processed)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
#ifndef SUPPRESS_IN_APP_APPEARANCE_ALERT
                [self showMessageBox:[NSString stringWithFormat:@"%@ has appeared", [availableScanner getScannerName]]];
#endif
            });
        }
    }
}

- (void)sbtEventScannerDisappeared:(int)scannerID
{
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    NSString *scannerName = [[[NSString alloc] initWithString:@""] retain];
    
    /* update dev list */
    BOOL found = NO;
    BOOL was_active = NO;
    
    if (YES == [m_ScannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (SbtScannerInfo *ex_info in [[m_ScannerInfoList copy] autorelease])
        {
            if ([ex_info getScannerID] == scannerID)
            {
                /* find scanner with ID in dev list */
                was_active = [ex_info isActive];
                scannerName = [[ex_info getScannerName] copy];
                
                [ex_info setAvailable:NO];

                found = YES;
                break;
            }
        }
        
        /* destroy barcode list for disappeared active scanner */
        if ((YES == found) && (YES == was_active))
        {
            for (int i = 0; i < [m_ScannerBarcodeList count]; i++)
            {
                if (scannerID == [(zt_BarcodeList*)[m_ScannerBarcodeList objectAtIndex:i] getScannerID])
                {
                    [m_ScannerBarcodeList removeObjectAtIndex:i];
                    break;
                }
            }
        }
        
        [m_ScannerInfoListGuard unlock];
    }
    
    NSString *notification = [NSString stringWithFormat:@"%@ has disappeared", scannerName];

    
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether available notifications are enabled */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_AVAILABLE] == YES)
        {
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:scannerID] forKey:ZT_NOTIFICATION_KEY_SCANNER_ID];
            [self showBackgroundNotification:notification aDictionary:notif_dict];
        }
    }
    
    /* notify connections delegates */
    for (id<IScannerAppEngineDevConnectionsDelegate> delegate in [[m_DevConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            result = [delegate scannerHasDisappeared:scannerID];
            if (result == YES)
            {
                /*
                 DevConnections delegates should NOT display any UI alerts,
                 so from UI notification side the event is not processed
                 */
                notificaton_processed = NO;
            }
        }
    }
    
    /* notify dev list delegates */
    for (id<IScannerAppEngineDevListDelegate> delegate in [[m_DevListDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            result = [delegate scannersListHasBeenUpdated];
            if (result == YES)
            {
                /*
                 DevList delegates should NOT display any UI alerts,
                 so from UI notification side the event is not processed
                 */
                
                notificaton_processed = NO;
            }
        }
    }
    
    if ([self isInBackgroundMode] == NO)
    {
        if (notificaton_processed == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
#ifndef SUPPRESS_IN_APP_DISAPPEARANCE_ALERT
               [self showMessageBox:notification];
#endif
            });
        }
    }
    
    [scannerName release];
}

- (void)sbtEventCommunicationSessionEstablished:(SbtScannerInfo*)activeScanner
{
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    
    /* update dev list */
    BOOL found = NO;
    
    if (YES == [m_ScannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (SbtScannerInfo *ex_info in [[m_ScannerInfoList copy] autorelease])
        {
            if ([ex_info getScannerID] == [activeScanner getScannerID])
            {
                /* find scanner with ID in dev list */
                [ex_info setActive:[activeScanner isActive]];
                [ex_info setAutoCommunicationSessionReestablishment:[activeScanner getAutoCommunicationSessionReestablishment]];
                [ex_info setConnectionType:[activeScanner getConnectionType]];
                found = YES;
                break;
            }
        }
        
        if (found == YES)
        {
            /* create new barcode list for connected active scanner */
            zt_BarcodeList *barcode_lst = [[zt_BarcodeList alloc] initWithMotoID:[activeScanner getScannerID] andName:[activeScanner getScannerName]];
            [m_ScannerBarcodeList addObject:barcode_lst];
            [barcode_lst release];
        }

        [m_ScannerInfoListGuard unlock];
    }
    
    NSString *notification = [NSString stringWithFormat:@"%@ has connected", [activeScanner getScannerName]];

    if (found)
    {
        if ([self isInBackgroundMode] == YES)
        {
            /* check whether active notifications are enabled */
            if ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_ACTIVE] == YES)
            {
                NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[activeScanner getScannerID]] forKey:ZT_NOTIFICATION_KEY_SCANNER_ID];
                [self showBackgroundNotification:notification aDictionary:notif_dict];
            }
        }
        
        /* notify connections delegates */
        for (id<IScannerAppEngineDevConnectionsDelegate> delegate in [[m_DevConnectionsDelegates copy] autorelease])
        {
            if (delegate != nil)
            {
                result = [delegate scannerHasConnected:[activeScanner getScannerID]];
                if (result == YES)
                {
                    /*
                     DevConnections delegates should NOT display any UI alerts,
                     so from UI notification side the event is not processed
                     */
                    notificaton_processed = NO;
                }
            }
        }

        /* notify dev list delegates */
        for (id<IScannerAppEngineDevListDelegate> delegate in [[m_DevListDelegates copy] autorelease])
        {
            if (delegate != nil)
            {
                result = [delegate scannersListHasBeenUpdated];
                if (result == YES)
                {
                    /*
                     DeList delegates should NOT display any UI alerts,
                     so from UI notification side the event is not processed
                     */
                    
                    notificaton_processed = NO;
                }
            }
        }

        if ([self isInBackgroundMode] == NO)
        {
            if (NO == notificaton_processed)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
    #ifndef SUPPRESS_IN_APP_CONNECTION_ALERT
                    [self showMessageBox:notification];
    #endif
                });
            }
        }
    }
    
    [self blinkLEDOff];
}

- (void)blinkLEDOff
{
    //red LED off
    NSString *in_xml_LED = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-int>%d</arg-int></cmdArgs></inArgs>", [[ConnectionManager sharedConnectionManager] getConnectedScannerId], RMD_ATTR_VALUE_ACTION_FAST_BLINK_OFF];
    [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_SET_ACTION aInXML:in_xml_LED aOutXML:nil forScanner:[[ConnectionManager sharedConnectionManager] getConnectedScannerId]];
}

- (void)blinkLEDON
{
    //red LED on
    NSString *in_xml_LED = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-int>%d</arg-int></cmdArgs></inArgs>", [[ConnectionManager sharedConnectionManager] getConnectedScannerId], RMD_ATTR_VALUE_ACTION_FAST_BLINK];
    [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_SET_ACTION aInXML:in_xml_LED aOutXML:nil forScanner:[[ConnectionManager sharedConnectionManager] getConnectedScannerId]];
}


- (void)sbtEventCommunicationSessionTerminated:(int)scannerID
{
    BOOL notificaton_processed = NO;
    BOOL result = NO;
    NSString *scannerName = [[[NSString alloc] initWithString:@""] retain];
    
    /* update dev list */
    BOOL found = NO;
    
    if (YES == [m_ScannerInfoListGuard lockBeforeDate:[NSDate distantFuture]])
    {
        for (SbtScannerInfo *ex_info in [[m_ScannerInfoList copy] autorelease])
        {
            if ([ex_info getScannerID] == scannerID)
            {
                /* find scanner with ID in dev list */
                [ex_info setActive:NO];
                scannerName = [[ex_info getScannerName] copy];
                found = YES;
                break;
            }
        }
        
        /* destroy barcode list for disconnected active scanner */
        if (YES == found)
        {
            for (int i = 0; i < [m_ScannerBarcodeList count]; i++)
            {
                if (scannerID == [(zt_BarcodeList*)[m_ScannerBarcodeList objectAtIndex:i] getScannerID])
                {
                    [m_ScannerBarcodeList removeObjectAtIndex:i];
                    break;
                }
            }
        }
        
        [m_ScannerInfoListGuard unlock];
    }
    
    
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether active notifications are enabled */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_ACTIVE] == YES)
        {
            NSString *notif_str = [NSString stringWithFormat:@"%@ has disconnected", scannerName];
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:scannerID] forKey:ZT_NOTIFICATION_KEY_SCANNER_ID];
            [self showBackgroundNotification:notif_str aDictionary:notif_dict];
        }
    }
    
    /* notify connections delegates */
    for (id<IScannerAppEngineDevConnectionsDelegate> delegate in [[m_DevConnectionsDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            result = [delegate scannerHasDisconnected:scannerID];
            if (result == YES)
            {
                /*
                 DevConnections delegates should NOT display any UI alerts,
                 so from UI notification side the event is not processed
                 */
                notificaton_processed = NO;
            }
        }
    }
    
    /* notify dev list delegates */
    for (id<IScannerAppEngineDevListDelegate> delegate in [[m_DevListDelegates copy] autorelease])
    {
        if (delegate != nil)
        {
            result = [delegate scannersListHasBeenUpdated];
            if (result == YES)
            {
                /*
                 DeList delegates should NOT display any UI alerts,
                 so from UI notification side the event is not processed
                 */
                notificaton_processed = NO;
            }
        }
    }
    
    
    if ([self isInBackgroundMode] == NO)
    {
        if (notificaton_processed == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                    #ifndef SUPPRESS_IN_APP_DISCONNECTION_ALERT
                        [self showMessageBox:[NSString stringWithFormat:@"%@ has disconnected", scannerName]];
                    #endif
            });
        }
    }
    
    [scannerName release];
}


- (void) sbtEventBarcode:(NSString *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID
{
    // Deprecated. Use sbtEventBarcodeData
    
    BarCodeList *barcodelist = [BarCodeList new];
    [barcodelist dataUpdatedWithBarcode:barcodeData];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BarcodeDetected" object:self];
    
    //BarCodeList *active_vc1 = (BarCodeList*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"BarCodeList"];
    //[self.navigationController presentViewController:active_vc1 animated:false completion:nil];
    
}

- (void)sbtEventBarcodeData:(NSData*)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID
{

    NSString *scannerName = [[[NSString alloc] initWithString:@""] retain];
    /* add new barcode to barcode list of specified scanner */
    for (zt_BarcodeList *barcode_lst in [[m_ScannerBarcodeList copy] autorelease])
    {
        if (scannerID == [barcode_lst getScannerID])
        {
            zt_BarcodeData *decode_data = [[zt_BarcodeData alloc] initWithData:barcodeData ofType:barcodeType];
            [barcode_lst addBarcodeData:decode_data];
            scannerName = [[barcode_lst getScannerName] copy];
            [decode_data release];
        }
    }
    
    /* process in a background mode */
    if ([self isInBackgroundMode] == YES)
    {
        /* check whether barcode notifications are enabled */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_BARCODE] == YES)
        {
            zt_BarcodeData *barcode = [[zt_BarcodeData alloc] initWithData:barcodeData ofType:barcodeType];
            
            NSString *notif_str = [NSString stringWithFormat:@"Barcode [%@] (%@) is received from %@", [barcode getDecodeDataAsStringUsingEncoding:NSUTF8StringEncoding], get_barcode_type_name(barcodeType), scannerName];
            
            [barcode release];
            
            NSDictionary *notif_dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:scannerID], ZT_NOTIFICATION_KEY_SCANNER_ID, [NSNumber numberWithBool:YES], ZT_NOTIFICATION_KEY_BARCODE, nil];
            [self showBackgroundNotification:notif_str aDictionary:notif_dict];
        }
    }

    /* notify correponding delegate */
    for (id<IScannerAppEngineDevEventsDelegate> delegate in [[m_DevEventsDelegates copy] autorelease])
    {
        /*
         Do not display barcode information if data is invalid.
         assume that data is invalid when barcodeData is null and barcodeType
         is NOT APPLICABLE.
         */
        if (delegate != nil && barcodeData != nil && barcodeType != ST_NOT_APP)
        {
            [delegate scannerBarcodeEvent:barcodeData barcodeType:barcodeType fromScanner:scannerID];
        }
        
        
    }
    
    [scannerName release];
}

- (void)sbtEventFirmwareUpdate:(FirmwareUpdateEvent *)fwUpdateEventObj
{
    for (id<IScannerAppEngineFWUpdateEventsDelegate> delegate in [[m_FWUpdateProgressDelegateList copy] autorelease])
    {
        /*
         Do not display barcode information if data is invalid.
         assume that data is invalid when barcodeData is null and barcodeType
         is NOT APPLICABLE.
         */
        if (delegate != nil) {
            if (delegate != nil && fwUpdateEventObj != nil && [delegate conformsToProtocol:@protocol(IScannerAppEngineFWUpdateEventsDelegate)])
            {
                [delegate updateUI:fwUpdateEventObj];
            }
        }
    }
}

/* TBD */
- (void)sbtEventImage:(NSData*)imageData fromScanner:(int)scannerID
{
    
}

/* TBD */
- (void)sbtEventVideo:(NSData*)videoFrame fromScanner:(int)scannerID
{
    
}

- (BOOL)firmwareDidUpdate
{
    return didFWUpdate;
}

- (int)previousScannerId
{
    return previousScanner;
}
- (void)setFirmwareDidUpdate:(BOOL)updateStatus
{
    didFWUpdate = updateStatus;
}

- (void)previousScannerpreviousScanner:(int)scannerIdStatus
{
    previousScanner = scannerIdStatus;
}
@end
