//
//  ZYXCPhotoCollectionViewCell.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYPhotoCollectionViewCell.h"
#import "UIImageView+ALAsset.h"
#import "DACircularProgressView.h"
#import "SDImageCache.h"


@interface ZYPhotoCollectionViewCell ()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) DACircularProgressView* progressView;

@end


@implementation ZYPhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.imageView = [UIImageView new];
		self.imageView.backgroundColor = [UIColor whiteColor];
		[self addSubview:self.imageView];
		
		self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
		self.progressView.roundedCorners = YES;
		self.progressView.trackTintColor = [UIColor whiteColor];
		self.progressView.progressTintColor = [UIColor grayColor];
		[self addSubview:self.progressView];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadProgressChanged:)
                                                 name:@"ZYXCUploadProgressChanged"
                                               object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
																									name:@"ZYXCUploadProgressChanged"
																								object:nil];
}

- (void)uploadProgressChanged:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSString* photoMd5 = userInfo[@"kPhotoMD5"];
	NSNumber* progress = userInfo[@"kProgress"];
	if ([photoMd5 isEqualToString:self.photo.md5]) {
		self.progressView.progress = [progress floatValue];
	}
}

- (void)layoutSubviews {
	self.imageView.frame = self.bounds;
	self.progressView.frame = CGRectMake(32.0f, 32.0f, 40.0f, 40.0f);
}

- (void)setPhoto:(ZYPhoto *)photo {
	_photo = photo;
	self.imageView.image = nil;
	self.progressView.progress = 0.0f;
	
	if (photo.state == ZYXCPhotoStateUploaded) {
		self.progressView.hidden = YES;
	} else {
		self.progressView.hidden = NO;
	}
	
	[self.imageView setImageWithAssetURL:photo.assetURL];
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
