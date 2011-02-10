//
//  EarthquakeCell.h
//  AdMobSampleAdsiPad
//
//  Copyright 2010 Admob. Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EarthquakeCell : UITableViewCell {

}

- (id)initWithLocation:(NSString *)location
                  date:(NSDate *)date
             magnitude:(CGFloat)magnitude
       reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setLocation:(NSString *)location;
- (void)setDate:(NSDate *)date;
- (void)setMagnitude:(CGFloat)magnitude;

@end
