//
//  UIImage+MD5.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "UIImage+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation UIImage (MD5)

- (NSString*)md5 {
	CGDataProviderRef dataProvider = CGImageGetDataProvider(self.CGImage);
	NSData* data = (NSData*)CFBridgingRelease(CGDataProviderCopyData(dataProvider));
	
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(data.bytes, data.length, digest);

	char hash[2 * sizeof(digest) + 1];
	for (size_t i = 0; i < sizeof(digest); ++i) {
		snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
	}
	return [NSString stringWithUTF8String:hash];
}

@end
