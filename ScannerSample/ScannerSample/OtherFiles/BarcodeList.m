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
 *  Description:  BarcodeList.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BarcodeList.h"

@implementation zt_BarcodeList

- (id)initWithMotoID:(int)moto_id andName:(NSString *)scannerName
{
    self = [super init];
	if (self != nil)
    {
        m_MotoScannerID = moto_id;
        m_BarcodeList = [[NSMutableArray alloc] init];
        m_ScannerName = [[NSString alloc] initWithString:scannerName];
    }
    return self;
}

- (void)dealloc
{
    if (m_BarcodeList != nil)
    {
        [m_BarcodeList removeAllObjects];
        [m_BarcodeList release];
        [m_ScannerName release];
    }
    [super dealloc];
}

- (int)getScannerID
{
    return m_MotoScannerID;
}

- (NSArray*)getBarcodeList
{
    return m_BarcodeList;
}

- (NSString *) getScannerName
{
    return m_ScannerName;
}

- (void) clearBarcodeList
{
    [m_BarcodeList removeAllObjects];
}

- (void)addBarcodeData:(zt_BarcodeData*)decode_data
{
    if (m_BarcodeList != nil)
    {
        [m_BarcodeList addObject:decode_data];
    }
}

@end
