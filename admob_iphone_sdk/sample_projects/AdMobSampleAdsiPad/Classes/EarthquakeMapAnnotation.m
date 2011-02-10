//
//  EarthquakeMapAnnotation.m
//  AdMobSampleAdsiPad
//
//  Copyright 2010 Admob. Inc. All rights reserved.
//

#import "EarthquakeMapAnnotation.h"

static NSDateFormatter *dateFormatter = nil;

@implementation EarthquakeMapAnnotation

@synthesize coordinate;

-(id)initWithEarthquake:(Earthquake *)earthquake {
  if (dateFormatter == nil) {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
  }

  self = [super init];
  if (self != nil) {
    coordinate.latitude = earthquake.latitude;
    coordinate.longitude = earthquake.longitude;
    title = [[NSString alloc] initWithFormat:@"%@ (%.1f)", earthquake.location, earthquake.magnitude];
    subtitle = [[dateFormatter stringFromDate:earthquake.date] retain];
  }
	return self;
}

- (CLLocationCoordinate2D)coordinate {
  return coordinate;
}

- (NSString *)title {
  return title;
}

- (NSString *)subtitle {
  return subtitle;
}

- (void)dealloc {
  [title release];
  [subtitle release];
  [super dealloc];
}

@end
