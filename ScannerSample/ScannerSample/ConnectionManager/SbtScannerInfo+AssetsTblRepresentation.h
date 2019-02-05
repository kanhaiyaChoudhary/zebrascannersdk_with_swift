//
//  SbtScannerInfo+AssetsTblRepresentation.h
//  ScannerSDKApp
//
//  Created by pqj647 on 10/19/15.
//  Copyright © 2015 pqj647. All rights reserved.
//

#import "SbtScannerInfo.h"

@interface SbtScannerInfo (AssetsTblRepresentation)
@property (nonatomic, retain) NSMutableDictionary *resultDictionary;

- (NSMutableDictionary*)getAssetsTblRepresentation:(void (^)(NSMutableDictionary *dictionary))competionHnadler;
- (void)setResultDictionary:(NSMutableDictionary *)resultDictionary;
- (NSMutableDictionary*)getResultDictionary;

@end
