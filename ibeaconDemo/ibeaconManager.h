//
//  ibeaconManager.h
//  ibeaconDemo
//
//  Created by winter on 2020/4/28.
//  Copyright © 2020 winter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ibeaconManager : NSObject
+ (instancetype)sharedInstance;
- (void)getScanningAllBeacon;
- (void)updateTheBeaconRegionWithConnectDevice;
@end

NS_ASSUME_NONNULL_END
