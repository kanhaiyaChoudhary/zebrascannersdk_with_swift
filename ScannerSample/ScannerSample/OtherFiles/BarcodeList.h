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
 *  Description:  BarcodeList.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "DecodeEvent.h"

@interface zt_BarcodeList : NSObject
{
    int m_MotoScannerID;
    NSString *m_ScannerName;
    NSMutableArray *m_BarcodeList;
}

- (id)initWithMotoID:(int)moto_id andName:(NSString *)scannerName;
- (void)dealloc;

- (int)getScannerID;
- (NSArray*)getBarcodeList;
- (NSString *)getScannerName;
- (void) clearBarcodeList;
- (void)addBarcodeData:(zt_BarcodeData*)decode_data;

@end
