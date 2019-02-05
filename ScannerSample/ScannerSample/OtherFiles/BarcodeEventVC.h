/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
  *  Description:  BarcodeEventVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "DecodeEvent.h"

@interface zt_BarcodeEventVC : UIViewController
{
    zt_BarcodeData *m_BarcodeData;
    int m_ScannerID;
    BOOL m_Child;
    IBOutlet UILabel *m_lblScannerID;
    IBOutlet UILabel *m_lblBarcodeType;
    IBOutlet UILabel *m_lblBarcodeData;
}

- (void)configureAsChild;
- (BOOL)isChildOfActiveVC;
- (void)setBarcodeEventData:(zt_BarcodeData*)barcodeData fromScanner:(int)scannerID;
- (void)dismissAction;
- (void)updateBarcodeUI;

@end
