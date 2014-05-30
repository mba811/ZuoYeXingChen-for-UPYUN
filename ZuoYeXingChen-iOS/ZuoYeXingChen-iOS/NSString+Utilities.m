//
//  NSString+Utilities.m
//  iOS-SDK-for-UPYUN
//
//  Created by tao on 5/11/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "NSString+Utilities.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Utilities)

- (NSString*)base64Encoding {
	NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [plainData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)md5 {
	const char* input = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(input, (CC_LONG)strlen(input), result);
	
	NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[digest appendFormat:@"%02X", result[i]];
	}
	
	return digest;
}

@end
