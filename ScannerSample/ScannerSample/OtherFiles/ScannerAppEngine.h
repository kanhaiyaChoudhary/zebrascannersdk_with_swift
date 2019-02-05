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
 *  Description:  ScannerAppEngine.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "ISbtSdkApi.h"
#import "SbtScannerInfo.h"

#define SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG

#define SST_SCANNER_MODEL_SSI_RFD8500       @"RFD8500"
#define SST_SCANNER_MODEL_SSI_CS4070        @"CS4070"
#define SST_SCANNER_MODEL_SSI_LI3678        @"LI3678"
#define SST_SCANNER_MODEL_SSI_DS3678        @"DS3678"
#define SST_SCANNER_MODEL_SSI_DS8178        @"DS8178"
#define SST_SCANNER_MODEL_SSI_DS2278        @"DS2278"
#define SST_SCANNER_MODEL_SSI_GENERIC       @"Generic SSI"
#define SST_SCANNER_MODEL_RFID_RFD8500      @"RFD8500-RFID"
#define SST_SCANNER_MODEL_UNKNOWN           @"Unknown"

@class BarCodeList;

@protocol IScannerAppEngineDevListDelegate <NSObject>
- (BOOL)scannersListHasBeenUpdated;
@end

@protocol IScannerAppEngineDevConnectionsDelegate <NSObject>
- (BOOL)scannerHasAppeared:(int)scannerID;
- (BOOL)scannerHasDisappeared:(int)scannerID;
- (BOOL)scannerHasConnected:(int)scannerID;
- (BOOL)scannerHasDisconnected:(int)scannerID;
@end

@protocol IScannerAppEngineDevEventsDelegate <NSObject>
- (void)scannerBarcodeEvent:(NSData*)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID;
/* nrv364: 
 called to show UI related to particular scanner on reception of local notification 
 mot_ScannerAppVC is currently the only class which implements DevEventsDelegate
 probably should be moved to another protocol when there will be more classes that
 implements DevEventsDelegate
*/
- (void)showScannerRelatedUI:(int)scannerID barcodeNotification:(BOOL)barcode;
@end

@protocol IScannerAppEngineFWUpdateEventsDelegate <NSObject>
- (void)updateUI:(FirmwareUpdateEvent*)event;
@end

@interface zt_ScannerAppEngine : NSObject <ISbtSdkApiDelegate>
{
    id <ISbtSdkApi> m_DcsSdkApi;
    NSMutableArray *m_DevListDelegates;
    NSMutableArray *m_DevConnectionsDelegates;
    NSMutableArray *m_DevEventsDelegates;
    /* TBD: access to list by idx should be synchronized */
    NSMutableArray *m_ScannerInfoList;
    NSMutableArray *m_ScannerBarcodeList;
    NSMutableArray *m_UINotificationList;
    NSMutableArray *m_FWUpdateProgressDelegateList;
    
    NSLock *m_ScannerInfoListGuard;
    BOOL m_BusyScannerAction;
}

+ (zt_ScannerAppEngine *) sharedAppEngine;
+ (id)alloc;
+ (void)destroy;
- (id)init;
- (void)dealloc;

- (void)initializeDcsSdkWithAppSettings;

/* Utility functions */

- (void)showMessageBox:(NSString*)message;
- (int)showBackgroundNotification:(NSString *)text aDictionary:(NSDictionary*)param_dict;
- (int)processBackroundNotification:(UILocalNotification*)notification;
- (int)dismissBackgroundNotifications;
- (BOOL)isInBackgroundMode;
- (void)fillScannersList:(NSMutableArray**)list;
- (NSString*)getScannerModelName:(int)scannerModel;

/* API calls for UI View Controllers */

- (void)addDevListDelegate:(id<IScannerAppEngineDevListDelegate>)delegate;
- (void)addDevConnectionsDelegate:(id<IScannerAppEngineDevConnectionsDelegate>)delegate;
- (void)addDevEventsDelegate:(id<IScannerAppEngineDevEventsDelegate>)delegate;
- (void)removeDevListDelegate:(id<IScannerAppEngineDevListDelegate>)delegate;
- (void)removeDevConnectiosDelegate:(id<IScannerAppEngineDevConnectionsDelegate>)delegate;
- (void)removeDevEventsDelegate:(id<IScannerAppEngineDevEventsDelegate>)delegate;
- (void)addFWUpdateEventsDelegate:(id<IScannerAppEngineFWUpdateEventsDelegate>)delegate;
- (void)removeFWUpdateEventsDelegate:(id<IScannerAppEngineFWUpdateEventsDelegate>)delegate;

- (NSArray*)getCompleteScannersList;
- (NSArray*)getAvailableScannersList;
- (SbtScannerInfo*)getScannerInfoByIdx:(int)dev_index;
- (SbtScannerInfo*)getScannerByID:(int)scanner_id;
- (void)raiseDeviceNotificationsIfNeeded;
- (NSArray*)getScannerBarcodesByID:(int)scanner_id;
- (void)clearScannerBarcodesByID:(int)scanner_id;

/* Interface for DCS SDK */

- (void)updateScannersList;
- (void)connect:(int)scanner_id;
- (void)disconnect:(int)scanner_id;
- (SBT_RESULT)setAutoReconnectOption:(int)scanner_id enableOption:(BOOL)enable;
- (void)enableScannersDetection:(BOOL)enable;
- (void)configureNotificationAvailable:(BOOL)enable;
- (void)configureNotificationActive:(BOOL)enable;
- (void)configureNotificationBarcode:(BOOL)enable;
- (void)configureNotificationImage:(BOOL)enable;
- (void)configureNotificationVideo:(BOOL)enable;
- (void)configureOperationalMode:(int)mode;
- (SBT_RESULT)executeCommand:(int)opCode aInXML:(NSString*)inXML aOutXML:(NSMutableString**)outXML forScanner:(int)scannerID;
- (SBT_RESULT)beepControl:(int)beepCode forScanner:(int)scannerID;
- (SBT_RESULT)ledControl:(BOOL)enable aLedCode:(int)ledCode forScanner:(int)scannerID;
- (NSString*)getSDKVersion;
- (void)setBluetoothAddress:(NSString*)blAddress;
- (UIImage*) sbtSTCPairingBarcode:(BARCODE_TYPE)barcodeType withComProtocol:(STC_COM_PROTOCOL)comProtocol withSetDefaultStatus:(SETDEFAULT_STATUS)setDefaultsStatus withBTAddress:(NSString*)btAddress withImageFrame:(CGRect)imageFrame;
- (BOOL)firmwareDidUpdate;
- (int)previousScannerId;
- (void)setFirmwareDidUpdate:(BOOL)updateStatus;
- (void)previousScannerpreviousScanner:(int)scannerIdStatus;
- (void)blinkLEDOff;
- (void)blinkLEDON;

- (void)setAutoReconnectOptionAfterScannerConnected:(int)scanner_id;
@end
