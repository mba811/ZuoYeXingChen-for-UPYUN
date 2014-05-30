//
//  ZYXCNetworkManager.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/20/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYNetworkManager.h"


static NSString* const BaseURLString = @"http://zyxc.avosapps.com/";


@implementation ZYNetworkManager

+ (ZYNetworkManager*)defaultManager {
	static dispatch_once_t pred;
	static ZYNetworkManager *instance = nil;
	dispatch_once(&pred, ^{instance = [[self alloc] initSingleton];});
	return instance;
}

- (id)initSingleton {
	NSURL *baseURL = [NSURL URLWithString:BaseURLString];
	self = [super initWithBaseURL:baseURL];
	if (self) {
		self.requestSerializer = [AFJSONRequestSerializer serializer];
		self.responseSerializer = [AFJSONResponseSerializer serializer];
	}
	return self;
}

@end
