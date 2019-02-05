//
//  SbtScannerInfo+AssetsTblRepresentation.m
//  ScannerSDKApp
//
//  Created by pqj647 on 10/19/15.
//  Copyright © 2015 pqj647. All rights reserved.
//

#import "SbtScannerInfo+AssetsTblRepresentation.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "RMDAttributes.h"
#import "config.h"
#import <objc/runtime.h>

NSString const *kPropertyKeyrsltsDic = @"kPropertyKeyrsltsDic";
NSString const *ID = @"ID";
NSString const *MODEL = @"Model";
NSString const *SERIAL_NO = @"Serial No.";
NSString const *CONFIG = @"Configuration";
NSString const *FRMVER = @"Firmware";
NSString const *MFD = @"Date of Manufactured";

@implementation SbtScannerInfo (AssetsTblRepresentation)

@dynamic resultDictionary;

- (NSMutableDictionary*)getAssetsTblRepresentation:(void (^)(NSMutableDictionary *dictionary))competionHnadler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        [self getScannerInfo];
    });
    NSMutableDictionary *resultDic = @{@"titles":@[ID, MODEL, SERIAL_NO, CONFIG, FRMVER, MFD],
                                       @"values":@[[NSString stringWithFormat:@"%d",[self getScannerID]], [NSString stringWithFormat:@"%@",self.scannerModelString == nil ? @"":self.scannerModelString], self.serialNo == nil ? @"":self.serialNo, [self getConfugurationType], self.firmwareVersion == nil ? @"":self.firmwareVersion, self.mFD == nil ? @"": self.mFD]
                                       }.mutableCopy;
    
    [self setResultDictionary:resultDic];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray *arrTemp = ((NSArray*)[[self getResultDictionary] valueForKey:@"values"]).mutableCopy;
        if (self.scannerModelString) {
            arrTemp[1] = self.scannerModelString;
        }
        if (self.serialNo) {
            arrTemp[2] = self.serialNo;
        }
        if (self.firmwareVersion) {
            arrTemp[4] = self.firmwareVersion;
        }
        if (self.mFD) {
            arrTemp[5] = self.mFD;
        }
        
        [[self getResultDictionary] setValue:arrTemp forKey:@"values"];
        competionHnadler([self getResultDictionary]);
    });
    return [self getResultDictionary];
}

- (void)setResultDictionary:(NSMutableDictionary *)resultDictionary {
    objc_setAssociatedObject(self, (__bridge const void *)(kPropertyKeyrsltsDic), resultDictionary, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary*)getResultDictionary {
    return objc_getAssociatedObject(self, (__bridge const void *)(kPropertyKeyrsltsDic));
}

- (NSString*)getConfugurationType {
    switch ([self getConnectionType])
    {
        case SBT_CONNTYPE_MFI:
            return @"MFi";
            break;
        case SBT_CONNTYPE_BTLE:
            return @"BT LE";
            break;
        default:
            return @"Unknown";
    }
}
//RMD_ATTR_MODEL_NUMBER

- (void)getScannerInfo {
    NSString *in_xml = nil;
    /**
     Model, MFD and serial no does not chage. So we need get the values for those variables only in the first time
     ***/
    if (!self.mFD || !self.serialNo || !self.scannerModelString) {
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d,%d,%d,%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, RMD_ATTR_FRMWR_VERSION, RMD_ATTR_MFD, RMD_ATTR_SERIAL_NUMBER, RMD_ATTR_MODEL_NUMBER];
    } else {
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, RMD_ATTR_FRMWR_VERSION];
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    [result setString:@""];
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
    
    if (SBT_RESULT_SUCCESS != res) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot retrieve asset information from the device"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                       }
                       );
        return;
        
    }
    
    BOOL success = FALSE;
    
    do {
        NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* tmp = @"<attrib_list><attribute>";
        NSRange range = [res_str rangeOfString:tmp];
        NSRange range2;
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        res_str = [res_str substringFromIndex:(range.location + range.length)];
        
        tmp = @"</attribute></attrib_list>";
        range = [res_str rangeOfString:tmp];
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        range.length = [res_str length] - range.location;
        
        res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
        
        NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute>"];
        
        if ([attrs count] == 0)
        {
            break;
        }
        
        NSString *attr_str;
        
        int attr_id;
        int attr_val;
        
        for (NSString *pstr in attrs)
        {
            attr_str = pstr;
            
            tmp = @"<id>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location != 0) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            tmp = @"</id>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range2.length = [attr_str length] - range.location;
            range2.location = range.location;
            
            NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            attr_id = [attr_id_str intValue];
            
            
            range2.location = 0;
            range2.length = range.location + range.length;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            tmp = @"<value>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str substringFromIndex:(range.location + range.length)];
            
            tmp = @"</value>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [attr_str length] - range.location;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            attr_val = [attr_str intValue];
            
            if (RMD_ATTR_FRMWR_VERSION == attr_id)
            {
                self.firmwareVersion = attr_str;
            }
            else if (RMD_ATTR_MFD == attr_id)
            {
                self.mFD = attr_str;
            } else if (RMD_ATTR_SERIAL_NUMBER == attr_id)
            {
                self.serialNo = attr_str;
            } else if(RMD_ATTR_MODEL_NUMBER == attr_id) {
                self.scannerModelString = attr_str;
            }
            else
            {
                break;
            }
        }
        
        success = TRUE;
        
    } while (0);
    
    if (FALSE == success)
    {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Error"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                       }
                       );
        return;
    }
    
}

@end
