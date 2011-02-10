//
//  EarthquakesLoader.m
//  AdMobSampleAdsiPad
//
//  Copyright 2010 Admob. Inc. All rights reserved.
//

#import "EarthquakesLoader.h"
#import <CFNetwork/CFNetwork.h>

#define EARTHQUAKE_FEED_URL @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml"

@interface EarthquakesLoader ()

- (void)addEarthquakesToList:(NSArray *)earthquakes;
- (void)handleError:(NSError *)error;

@end


@implementation EarthquakesLoader

@synthesize earthquakeList;
@synthesize delegate;
@synthesize earthquakeFeedConnection;
@synthesize earthquakeData;
@synthesize currentEarthquakeObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;

- (id)initWithDelegate:(id<EarthquakesLoaderDelegate>)d {
  self = [super init];
  if (self != nil) {
    earthquakeList = [[NSMutableArray alloc] init];
    delegate = d;

    NSURLRequest *earthquakeURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:EARTHQUAKE_FEED_URL]];
    self.earthquakeFeedConnection = [[[NSURLConnection alloc] initWithRequest:earthquakeURLRequest
                                                                     delegate:self] autorelease];
    NSAssert(self.earthquakeFeedConnection != nil, @"Failure to create URL connection.");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  }
  return self;
}

- (void)parseEarthquakeData:(NSData *)data {
  // You must create a autorelease pool for all secondary threads.
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  self.currentParseBatch = [NSMutableArray array];
  self.currentParsedCharacterData = [NSMutableString string];
  //
  // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable
  // because it gives less control over the network, particularly in responding to connection errors.
  //
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
  [parser setDelegate:self];
  [parser parse];
  
  // depending on the total number of earthquakes parsed, the last batch might not have been a "full" batch, and thus
  // not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
  if ([self.currentParseBatch count] > 0) {
    [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
  }
  self.currentParseBatch = nil;
  self.currentEarthquakeObject = nil;
  self.currentParsedCharacterData = nil;
  [parser release];        
  [pool release];
}

// Handle errors in the download or the parser by showing an alert to the user. This is a very simple way of handling the error,
// partly because this application does not have any offline functionality for the user. Most real applications should
// handle the error in a less obtrusive way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
  NSString *errorMessage = [error localizedDescription];
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}

// The secondary (parsing) thread calls addToEarthquakeList: on the main thread with batches of parsed objects. 
// The batch size is set via the kSizeOfEarthquakeBatch constant.
- (void)addEarthquakesToList:(NSArray *)earthquakes {
  [self.earthquakeList addObjectsFromArray:earthquakes];
  // notify the delegate
  [delegate earthquakesDidLoad:self];
}

- (void)dealloc {
  [earthquakeFeedConnection release];
  [earthquakeData release];
	[earthquakeList release];
  [currentEarthquakeObject release];
  [currentParsedCharacterData release];
  [currentParseBatch release];
	[super dealloc];
}

#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  self.earthquakeData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [earthquakeData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
  if ([error code] == kCFURLErrorNotConnectedToInternet) {
    // if we can identify the error, we can present a more precise message to the user.
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error",                             @"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
    NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:kCFURLErrorNotConnectedToInternet
                                                 userInfo:userInfo];
    [self handleError:noConnectionError];
  } else {
    // otherwise handle the error generically
    [self handleError:error];
  }
  self.earthquakeFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  self.earthquakeFeedConnection = nil;
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
  // Spawn a thread to fetch the earthquake data so that the UI is not blocked while the application parses the XML data.
  //
  // IMPORTANT! - Don't access UIKit objects on secondary threads.
  //
  [NSThread detachNewThreadSelector:@selector(parseEarthquakeData:) toTarget:self withObject:earthquakeData];
  // earthquakeData will be retained by the thread until parseEarthquakeData: has finished executing, so we no longer need
  // a reference to it in the main thread.
  self.earthquakeData = nil;
}

#pragma mark Parser constants

// Limit the number of parsed earthquakes to 50.
static const const NSUInteger kMaximumNumberOfEarthquakesToParse = 50;

// When an Earthquake object has been fully constructed, it must be passed to the main thread and the table view 
// in EarthquakeListViewController must be reloaded to display it. It is not efficient to do this for every Earthquake object -
// the overhead in communicating between the threads and reloading the table exceed the benefit to the user. Instead,
// we pass the objects in batches, sized by the constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
static NSUInteger const kSizeOfEarthquakeBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"entry";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kUpdatedElementName = @"updated";
static NSString * const kGeoRSSPointElementName = @"georss:point";

#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  // If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
  if (parsedEarthquakesCounter >= kMaximumNumberOfEarthquakesToParse) {
    // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
    didAbortParsing = YES;
    [parser abortParsing];
  }
  if ([elementName isEqualToString:kEntryElementName]) {
    Earthquake *earthquake = [[Earthquake alloc] init];
    self.currentEarthquakeObject = earthquake;
    [earthquake release];
  } else if ([elementName isEqualToString:kLinkElementName]) {
    NSString *relAttribute = [attributeDict valueForKey:@"rel"];
    if ([relAttribute isEqualToString:@"alternate"]) {
      NSString *USGSWebLink = [attributeDict valueForKey:@"href"];
      static NSString * const kUSGSBaseURL = @"http://earthquake.usgs.gov/";
      self.currentEarthquakeObject.USGSWebLink = [kUSGSBaseURL stringByAppendingString:USGSWebLink];
    }
  } else if ([elementName isEqualToString:kTitleElementName] || [elementName isEqualToString:kUpdatedElementName] || [elementName isEqualToString:kGeoRSSPointElementName]) {
    // For the 'title', 'updated', or 'georss:point' element, begin accumulating parsed character data.
    // The contents are collected in parser:foundCharacters:.
    accumulatingParsedCharacterData = YES;
    // The mutable string needs to be reset to empty.
    [currentParsedCharacterData setString:@""];
  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
  if ([elementName isEqualToString:kEntryElementName]) {
    [self.currentParseBatch addObject:self.currentEarthquakeObject];
    parsedEarthquakesCounter++;
    if (parsedEarthquakesCounter % kSizeOfEarthquakeBatch == 0) {
      [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
      self.currentParseBatch = [NSMutableArray array];
    }
  } else if ([elementName isEqualToString:kTitleElementName]) {
    // The title element contains the magnitude and location in the following format:
    // <title>M 3.6, Virgin Islands region<title/>
    // Extract the magnitude and the location using a scanner:
    NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
    // Scan past the "M " before the magnitude.
    [scanner scanString:@"M " intoString:NULL];
    CGFloat magnitude;
    [scanner scanFloat:&magnitude];
    self.currentEarthquakeObject.magnitude = magnitude;
    // Scan past the ", " before the title.
    [scanner scanString:@", " intoString:NULL];
    NSString *location = nil;
    // Scan the remainer of the string.
    [scanner scanUpToCharactersFromSet:[NSCharacterSet illegalCharacterSet]  intoString:&location];
    self.currentEarthquakeObject.location = location;
  } else if ([elementName isEqualToString:kUpdatedElementName]) {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    self.currentEarthquakeObject.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
  } else if ([elementName isEqualToString:kGeoRSSPointElementName]) {
    // The georss:point element contains the latitude and longitude of the earthquake epicenter.
    // 18.6477 -66.7452
    NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
    double latitude, longitude;
    [scanner scanDouble:&latitude];
    [scanner scanDouble:&longitude];
    self.currentEarthquakeObject.latitude = latitude;
    self.currentEarthquakeObject.longitude = longitude;
  }
  // Stop accumulating parsed character data. We won't start again until specific elements begin.
  accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not
// guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to
// accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (accumulatingParsedCharacterData) {
    // If the current element is one whose content we care about, append 'string'
    // to the property that holds the content of the current element.
    [self.currentParsedCharacterData appendString:string];
  }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  // If the number of earthquake records received is greater than kMaximumNumberOfEarthquakesToParse, we abort parsing.
  // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
  // how we distinguish real errors encountered by the parser.
  if (didAbortParsing == NO) {
    // Pass the error to the main thread for handling.
    [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
  }
}

@end
