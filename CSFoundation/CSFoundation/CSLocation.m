//
//  GIController.m
//  GI Group
//
//  Created by Andreas Liebschner on 6/7/12.
//  Copyright (c) 2012 CommonSense srl. All rights reserved.
//

#import "CSLocation.h"
#import "CSConfiguration.h"

@implementation CSLocation

@synthesize locationManager;
//, significantManager;
@synthesize currentLocation = _currentLocation;
@synthesize gpsLocation = _gpsLocation;

static CSLocation *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    
    if (initialized != YES) {
        initialized = YES;
        sharedSingleton = [[CSLocation alloc] init];
    }
}

+ (CSLocation *)sharedInstance
{
    return sharedSingleton;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        locationManager = [[CLLocationManager alloc] init];        
        locationManager.delegate = self;
        //significantManager = [[CLLocationManager alloc] init];        
        //significantManager.delegate = self;

    }

    return self;
}

- (void)dealloc
{
    //
    //[significantManager stopMonitoringSignificantLocationChanges];
}

- (void)startLocationUpdatesWithAccuracy:(CLLocationAccuracy)accuracy distance:(CLLocationDistance)distance
{
    locationManager.desiredAccuracy = accuracy; // kCLLocationAccuracyHundredMeters;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = distance;
    
    [locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //if application is running in background, check if a notification is needed
//TODO:        [NearbyNotification performBackgroundCheck:newLocation];
        return;
    }

    // If it's a relatively recent event, use it
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        self.currentLocation = [newLocation copy];
        self.gpsLocation = [newLocation copy];
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        
        [self performSelectorOnMainThread:@selector(postNotification:) 
                               withObject: [NSNotification notificationWithName:@"CLLocationChanged" 
                                                                         object:nil 
                                                                       userInfo:nil]
                            waitUntilDone:NO];            
        
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            NSLog(@"accuracy: %f needed: %f", newLocation.horizontalAccuracy, locationManager.desiredAccuracy);
            //this new measurement is accurate enough: let's use it as our location, and stop measurements
            [self stopUpdatingLocation];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
                
    } else {
        NSLog(@"location event too old, skipped");
    }
    // else skip the event and process the next one.
}

- (void)stopUpdatingLocation {
    [locationManager stopUpdatingLocation];
    
/*    
    BOOL proximity_settings = [NearbyNotification isProximityEnabled] ;    
    if (proximity_settings) {
        [significantManager startMonitoringSignificantLocationChanges];
    } else {
        [significantManager stopMonitoringSignificantLocationChanges];
    }
*/ 
}   

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (error.code ==  kCLErrorDenied) {
        NSLog(@"Location manager denied access - kCLErrorDenied");
        CSConfiguration *configuration = [CSConfiguration sharedInstance];
        NSString *displayed = [configuration GetValueForKey:@"CSLocationEnabledWarning"];
        
        if (!displayed) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CSLocation_AskPermissionTitle", @"CSLocation_AskPermissionTitle")
                                                            message:NSLocalizedString(@"CSLocation_AskPermission", @"CSLocation_AskPermission")
                                                           delegate:nil 
                                                  cancelButtonTitle:nil 
                                                  otherButtonTitles:nil];
            [alert show];
            
            [configuration SetValue:@"YES" ForKey:@"CSLocationEnabledWarning"];
            [configuration save];
        }
    }
}


- (void)postNotification:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];
}


@end
