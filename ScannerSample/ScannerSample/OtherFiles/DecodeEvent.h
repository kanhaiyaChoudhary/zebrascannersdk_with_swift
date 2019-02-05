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
 *  Description:  DecodeEvent.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface zt_BarcodeData : NSObject
{
    NSData *m_DecodeData;
    int m_DecodeType;
}

- (id)initWithData:(NSData*)barcode_data ofType:(int)barcode_type;
- (void)dealloc;

- (int)getDecodeType;
- (NSData*)getDecodeData;
- (NSString *)getDecodeDataAsStringUsingEncoding:(NSStringEncoding)encoding;


@end