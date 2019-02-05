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
 *  Description:  ScannersTableVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>
#import "ScannerAppEngine.h"

@interface zt_ScannersTableVC : UITableViewController <IScannerAppEngineDevListDelegate,IScannerAppEngineDevConnectionsDelegate>
{
    BOOL m_EmptyDeviceList;
    UIBarButtonItem *m_btnUpdateDevList;
    int m_CurrentScannerId;
    BOOL m_CurrentScannerActive;
    zt_AlertView *activityView;
}

- (void)showActiveScannerVC:(NSNumber*)scannerID aBarcodeView:(BOOL)barcodeView aAnimated:(BOOL)animated;
- (void)btnUpdateScannersListPressed;
- (void)updateScannersList;

@end
