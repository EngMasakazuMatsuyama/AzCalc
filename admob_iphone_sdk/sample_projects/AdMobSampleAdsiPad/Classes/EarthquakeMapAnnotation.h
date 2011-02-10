//
//  EarthquakeMapAnnotation.h
//  AdMobSampleAdsiPad
//
//  Copyright 2010 Admob. Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Earthquake.h"

@interface EarthquakeMapAnnotation : NSObject <MKAnnotation>
{
  CLLocationCoordinate2D coordinate;
  NSString *title;
  NSString *subtitle;
}

-(id)initWithEarthquake:(Earthquake *)earthquake;

@end
