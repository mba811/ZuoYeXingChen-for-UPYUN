//
//  ZYXCPhotoCollectionViewHeader.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYPhotoCollectionViewHeader.h"


@interface ZYPhotoCollectionViewHeader ()

@property (nonatomic, strong) UILabel* timeLabel;

@end


@implementation ZYPhotoCollectionViewHeader

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.timeLabel = [UILabel new];
		[self addSubview:self.timeLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.timeLabel.frame = CGRectMake(10, 2, 310, 40);
}

- (void)setDate:(NSDate*)date {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	
	self.timeLabel.text = [dateFormatter stringFromDate:date];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
