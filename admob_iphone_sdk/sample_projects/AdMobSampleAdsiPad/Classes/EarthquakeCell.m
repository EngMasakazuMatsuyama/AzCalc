//
//  EarthquakeCell.m
//  AdMobSampleAdsiPad
//
//  Copyright 2010 Admob. Inc. All rights reserved.
//

#import "EarthquakeCell.h"

static NSUInteger const kLocationLabelTag = 2;
static NSUInteger const kDateLabelTag = 3;
static NSUInteger const kMagnitudeLabelTag = 4;
static NSUInteger const kMagnitudeImageTag = 5;
static NSDateFormatter *dateFormatter = nil;

@implementation EarthquakeCell

// Based on the magnitude of the earthquake, return an image indicating its seismic strength.
- (UIImage *)imageForMagnitude:(CGFloat)magnitude {	
	if (magnitude >= 5.0) {
		return [UIImage imageNamed:@"5.0.png"];
	}
	if (magnitude >= 4.0) {
		return [UIImage imageNamed:@"4.0.png"];
	}
	if (magnitude >= 3.0) {
		return [UIImage imageNamed:@"3.0.png"];
	}
	if (magnitude >= 2.0) {
		return [UIImage imageNamed:@"2.0.png"];
	}
	return nil;
}

- (void)setMagnitudeLabel:(CGFloat)magnitude {
  UILabel *magnitudeLabel = (UILabel *)[self.contentView viewWithTag:kMagnitudeLabelTag];
  magnitudeLabel.text = [NSString stringWithFormat:@"%.1f", magnitude];
}

- (id)initWithLocation:(NSString *)location
                  date:(NSDate *)date
             magnitude:(CGFloat)magnitude
       reuseIdentifier:(NSString *)reuseIdentifier
{

  if (dateFormatter == nil) {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
  }
  
  if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
    UILabel *locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, 190, 20)] autorelease];
    locationLabel.tag = kLocationLabelTag;
    locationLabel.font = [UIFont boldSystemFontOfSize:14];
    locationLabel.text = location;
    [self.contentView addSubview:locationLabel];
    
    UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 28, 170, 14)] autorelease];
    dateLabel.tag = kDateLabelTag;
    dateLabel.font = [UIFont systemFontOfSize:10];
    dateLabel.text = [dateFormatter stringFromDate:date];
    [self.contentView addSubview:dateLabel];
    
    UILabel *magnitudeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(277, 9, 170, 29)] autorelease];
    magnitudeLabel.tag = kMagnitudeLabelTag;
    magnitudeLabel.font = [UIFont boldSystemFontOfSize:24];
    magnitudeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:magnitudeLabel];
    [self setMagnitudeLabel:magnitude];
    
    UIImage *magnitudeImage = [self imageForMagnitude:magnitude];
    UIImageView *magnitudeImageView = [[[UIImageView alloc] initWithImage:magnitudeImage] autorelease];
    CGRect imageFrame = magnitudeImageView.frame;
    imageFrame.origin = CGPointMake(180, 2);
    magnitudeImageView.frame = imageFrame;
    magnitudeImageView.tag = kMagnitudeImageTag;
    magnitudeImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:magnitudeImageView];
  }
  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setLocation:(NSString *)location {
  UILabel *locationLabel = (UILabel *)[self.contentView viewWithTag:kLocationLabelTag];
  locationLabel.text = location;
}

- (void)setDate:(NSDate *)date {
  UILabel *dateLabel = (UILabel *)[self.contentView viewWithTag:kDateLabelTag];
  dateLabel.text = [dateFormatter stringFromDate:date];
}

- (void)setMagnitude:(CGFloat)magnitude {
  [self setMagnitudeLabel:magnitude];
  UIImageView *magnitudeImageView = (UIImageView *)[self.contentView viewWithTag:kMagnitudeImageTag];
  magnitudeImageView.image = [self imageForMagnitude:magnitude];
}

- (void)dealloc {
    [super dealloc];
}


@end
