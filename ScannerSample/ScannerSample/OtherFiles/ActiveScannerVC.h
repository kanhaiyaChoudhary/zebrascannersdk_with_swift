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
 *  Description:  ActiveScannerVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "ScannerAppEngine.h"

@interface zt_ActiveScannerVC : UITabBarController <IScannerAppEngineDevConnectionsDelegate>
{
    int m_ScannerID;
    BOOL m_WillDisappear;
}

- (void)setScannerID:(int)scannerID;
- (int)getScannerID;
- (void)showBarcode;
- (void)showBarcodeList;
- (void)showSettingsPage;

@end
