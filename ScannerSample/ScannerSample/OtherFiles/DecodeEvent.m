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
 *  Description:  DecodeEvent.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "DecodeEvent.h"

@implementation zt_BarcodeData

- (id)initWithData:(NSData*)barcode_data ofType:(int)barcode_type
{
    self = [super init];
    if (self != nil)
    {
        m_DecodeType = barcode_type;
        m_DecodeData = [[NSData alloc] initWithData:barcode_data];
    }
    return self;
}

- (void)dealloc
{
    if (m_DecodeData != nil)
    {
        [m_DecodeData release];
    }
    [super dealloc];
}

- (int)getDecodeType
{
    return m_DecodeType;
}

- (NSData*)getDecodeData
{
    return m_DecodeData;
}

- (NSString *)getDecodeDataAsStringUsingEncoding:(NSStringEncoding)enc
{
    NSString *decodeDataString = [[NSString alloc] initWithBytes:((unsigned char*)[m_DecodeData bytes]) length:([m_DecodeData length]) encoding:enc];
    
    // If nil data is returned, display data bytes as string.
    if (decodeDataString == nil)
    {
        [decodeDataString release];
        
        unsigned char *bytes = (unsigned char*)[m_DecodeData bytes];
        
        NSMutableString *decodeDataBytesStr = [[NSMutableString alloc] initWithString:@"Data cannot be displayed as string:"];
        
        for (int i = 0; i < [m_DecodeData length]; i++)
        {
            [decodeDataBytesStr appendFormat:@"0x%02X ",bytes[i]];
        }
        
        decodeDataString = [[NSString alloc] initWithString:decodeDataBytesStr];
        [decodeDataBytesStr release];
    }
    
    return [decodeDataString autorelease];
}

@end