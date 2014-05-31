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
	NSURL* baseURL = [NSURL URLWithString:BaseURLString];
	self = [super initWithBaseURL:baseURL];
	if (self) {
		self.requestSerializer = [AFJSONRequestSerializer serializer];
		self.responseSerializer = [AFJSONResponseSerializer serializer];
	}
	return self;
}

- (void)getUploadedPhotosWithDirectory:(NSString*)directory
															 success:(void (^)(id responseObject))success
															 failure:(void (^)(NSError* error))failure {
	
	NSDictionary* parameters = @{@"directory": directory};
	
	[self GET:@"uploaded-photos" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failure(error);
	}];
}

@end
