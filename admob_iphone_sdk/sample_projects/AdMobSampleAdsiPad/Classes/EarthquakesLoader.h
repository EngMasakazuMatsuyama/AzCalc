//
//  EarthquakesLoader.h
//  AdMobSampleAdsiPad
//
//  Copyright 2010 Admob Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Earthquake.h"

@class EarthquakesLoader;

@protocol EarthquakesLoaderDelegate

- (void)earthquakesDidLoad:(EarthquakesLoader *)loader;

@end


@interface EarthquakesLoader : NSObject {
  NSMutableArray *earthquakeList;
  id<EarthquakesLoaderDelegate> delegate;
  
  // for download use
  NSURLConnection *earthquakeFeedConnection;
  NSMutableData *earthquakeData;

  // for parsing use
  Earthquake *currentEarthquakeObject;
  NSMutableArray *currentParseBatch;
  NSUInteger parsedEarthquakesCounter;
  NSMutableString *currentParsedCharacterData;
  BOOL accumulatingParsedCharacterData;
  BOOL didAbortParsing;
}

@property (nonatomic, retain) NSMutableArray *earthquakeList;
@property (nonatomic, assign) id<EarthquakesLoaderDelegate> delegate;

@property (nonatomic, retain) NSURLConnection *earthquakeFeedConnection;
@property (nonatomic, retain) NSMutableData *earthquakeData;

@property (nonatomic, retain) Earthquake *currentEarthquakeObject;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;

- (id)initWithDelegate:(id<EarthquakesLoaderDelegate>)d;

@end
