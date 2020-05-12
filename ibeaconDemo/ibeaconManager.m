//
//  ibeaconManager.m
//  ibeaconDemo
//
//  Created by winter on 2020/4/28.
//  Copyright © 2020 winter. All rights reserved.
//

#import "ibeaconManager.h"
#import <CoreLocation/CoreLocation.h>


static NSString *const ibeaconDeviceUUID = @"01122334-4556-6778-899a-abbccddeeff0";//
static NSString *const ibeaconMajor = @"01122334-4556-6778-899a-abbccddeeff0";//
static NSString *const ibeaconMinor = @"01122334-4556-6778-899a-abbccddeeff0";//

@interface ibeaconManager ()
<
CLLocationManagerDelegate
>
/** 检查定位权限 */
@property (nonatomic, strong) CLLocationManager *locationManager;
/** 需要被监听的beacon */
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
/** 需要被监听的beacon参数 */
@property (nonatomic, strong) CLBeaconIdentityConstraint *beaconConstrait;
@end

@implementation ibeaconManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestAlwaysAuthorization];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.delegate = self;
        //实时更新定位位置
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager startUpdatingLocation];
        
        NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:ibeaconDeviceUUID];
        if (@available(iOS 13.0, *)) {
            _beaconRegion = [[CLBeaconRegion alloc] initWithUUID:estimoteUUID identifier:@""];
            _beaconConstrait  = [[CLBeaconIdentityConstraint alloc] initWithUUID:estimoteUUID];
        }else{
            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID identifier:@""];
        }
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
        
    }
    return self;
}

- (void)checkMonitoringAuth
{
    // 在开始监控之前，我们需要判断改设备是否支持，和区域权限请求
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                [self.locationManager requestAlwaysAuthorization];
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                NSLog(@"受限制或者拒绝");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                if (@available(iOS 13.0, *)) {
                    [self.locationManager startRangingBeaconsSatisfyingConstraint:self.beaconConstrait];
                }else{
                    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
                }
                [self.locationManager startMonitoringForRegion:self.beaconRegion];
            }
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status  {
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (@available(iOS 13.0, *)) {
            [self.locationManager startRangingBeaconsSatisfyingConstraint:self.beaconConstrait];
        }else{
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        }
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

#pragma mark -- Monitoring
/** 进入区域 */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region  {
}


/** 离开区域 */
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region  {
}


/** Monitoring有错误产生时的回调 */
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error {
}

/** Monitoring 成功回调 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
}



#pragma mark -- Ranging
/** 1秒钟执行1次 */ //进入和离开、点亮屏幕也会调这个方法
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
        for (CLBeacon *beacon in beacons) {
            NSLog(@" rssi is :%ld",(long)beacon.rssi);
            NSLog(@" beacon proximity :%ld",(long)beacon.proximity);
            NSLog(@" accuracy : %f",beacon.accuracy);
            NSLog(@" proximityUUID : %@",beacon.proximityUUID.UUIDString);
            NSLog(@" major :%ld",(long)beacon.major.integerValue);
            NSLog(@" minor :%ld",(long)beacon.minor.integerValue);
        }
}

/** 1秒钟执行1次 */ //进入和离开、点亮屏幕也会调这个方法
- (void)locationManager:(CLLocationManager *)manager
     didRangeBeacons:(NSArray<CLBeacon *> *)beacons
satisfyingConstraint:(CLBeaconIdentityConstraint *)beaconConstraint
{
    for (CLBeacon *beacon in beacons) {
        NSLog(@" rssi is :%ld",(long)beacon.rssi);
        NSLog(@" beacon proximity :%ld",(long)beacon.proximity);
        NSLog(@" accuracy : %f",beacon.accuracy);
        NSLog(@" proximityUUID : %@",beacon.UUID.UUIDString);
        NSLog(@" major :%ld",(long)beacon.major.integerValue);
        NSLog(@" minor :%ld",(long)beacon.minor.integerValue);
    }
}

/** ranging有错误产生时的回调  */
- (void)locationManager:(CLLocationManager *)manager
didFailRangingBeaconsForConstraint:(CLBeaconIdentityConstraint *)beaconConstraint
                  error:(NSError *)error{
    
}
#pragma mark -- Kill callBack
/** 杀掉进程之后的回调，直接锁屏解锁，会触发 */
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
}



@end
