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
 *  Description:  ActiveScannerBarcodeVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AlertView.h"
#import <UIKit/UIKit.h>



@interface zt_ActiveScannerBarcodeVC : UITableViewController <UIAlertViewDelegate>
{
    int m_ScannerID;
    NSMutableArray *m_BarcodeList;
    zt_AlertView *activityView;
    BOOL m_HideModeSwitch;
    BOOL m_HideReleaseTrigger;
}

- (int)getScannerID;
- (void)setScannerID:(int)scannerID;
- (void)showBarcode;
- (void)performActionTriggerPull:(NSString*)param;
- (void)performActionTriggerRelease:(NSString*)param;
- (void)performActionBarcodeMode:(NSString*)param;

@end
