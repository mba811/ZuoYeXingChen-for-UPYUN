//
//  ZYXCPhoto.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYPhoto.h"


@implementation ZYPhoto

- (id)initWithMd5:(NSString*)md5
						 date:(NSDate*)date
						state:(ZYPhotoState)state {
	self = [super init];
	if (self) {
		self.md5 = md5;
		self.date = date;
		self.state = state;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.md5 = [decoder decodeObjectForKey:@"md5"];
		self.thumbnailURL = [decoder decodeObjectForKey:@"thumbnailURL"];
		self.date = [decoder decodeObjectForKey:@"date"];
		self.state = [decoder decodeIntForKey:@"state"];
		self.assetURL = [decoder decodeObjectForKey:@"assetURL"];
		self.asset = nil;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.md5 forKey:@"md5"];
	[encoder encodeObject:self.thumbnailURL forKey:@"thumbnailURL"];
	[encoder encodeObject:self.date forKey:@"date"];
	[encoder encodeInt:self.state forKey:@"state"];
	[encoder encodeObject:self.assetURL forKey:@"assetURL"];
}

@end
