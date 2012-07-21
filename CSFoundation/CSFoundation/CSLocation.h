//
//  GIController.h
//  GI Group
//
//  Created by Andreas Liebschner on 6/7/12.
//  Copyright (c) 2012 CommonSense srl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CSLocation : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
//@property (nonatomic, retain) CLLocationManager *significantManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *gpsLocation;

+ (CSLocation *)sharedInstance;

- (void)startLocationUpdatesWithAccuracy:(CLLocationAccuracy)accuracy distance:(CLLocationDistance)distance;
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
- (void)stopUpdatingLocation;



@end
