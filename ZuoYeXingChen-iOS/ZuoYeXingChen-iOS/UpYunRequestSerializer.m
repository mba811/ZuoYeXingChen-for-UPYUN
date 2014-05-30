//
//  UpYunRequestSerializer.m
//  iOS-SDK-for-UPYUN
//
//  Created by tao on 5/2/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "UpYunRequestSerializer.h"
#import "NSString+Utilities.h"


@implementation UpYunRequestSerializer

- (NSString*)policyWithBucket:(NSString*)bucket
											saveKey:(NSString*)saveKey
									 expiration:(NSTimeInterval)expiration
						 policyParameters:(NSDictionary*)policyParameters {
	
	expiration = [[NSDate date] timeIntervalSince1970] + expiration;
	NSString* expirationString = [NSString stringWithFormat:@"%.0f", expiration];
	
	NSDictionary* requiredParameters = @{@"bucket": bucket,
																			 @"expiration": expirationString,
																			 @"save-key": saveKey};
	NSMutableDictionary* policy = [NSMutableDictionary dictionaryWithDictionary:requiredParameters];
	
	if (policyParameters) {
		[policyParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			policy[key] = obj;
		}];
	}
	
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:policy
																										 options:0
																											 error:nil];
	if (!jsonData) {
		return nil;
	}
	
	NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

	return [jsonString base64Encoding];
}

- (NSString*)policySignatureWithBucketSecret:(NSString*)bucketSecret
																			policy:(NSString*)policy {
	return [[NSString stringWithFormat:@"%@&%@", policy, bucketSecret] md5];
}

- (NSMutableURLRequest*)multipartFormRequestWithUpYunAPIHost:(NSString*)APIHost
																											bucket:(NSString*)bucket
																								bucketSecret:(NSString*)bucketSecret
																										fileData:(NSData*)fileData
																										 saveKey:(NSString*)saveKey
																									expiration:(NSTimeInterval)expiration
																						policyParameters:(NSDictionary*)policyParameters {
	NSString* URLString = [NSString stringWithFormat:@"%@/%@", APIHost, bucket];
	
	NSString* policy = [self policyWithBucket:bucket
																		saveKey:saveKey
																 expiration:expiration
													 policyParameters:policyParameters];
	
	NSString* signature = [self policySignatureWithBucketSecret:bucketSecret
																											 policy:policy];
	
	NSDictionary* parameters = @{@"policy": policy,
															 @"signature": signature};
	
	void (^bodyBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
		[formData appendPartWithFileData:fileData
															 name:@"file"
													 fileName:@"file.jpg"
													 mimeType:@"multipart/form-data"];
	};
	
	NSMutableURLRequest* request = [super multipartFormRequestWithMethod:@"POST"
																														 URLString:URLString
																														parameters:parameters
																						 constructingBodyWithBlock:bodyBlock
																																 error:nil];
	return request;
}

- (NSMutableURLRequest*)multipartFormRequestWithUpYunAPIHost:(NSString*)APIHost
																											bucket:(NSString*)bucket
																								bucketSecret:(NSString*)bucketSecret
																										filePath:(NSString*)filePath
																										 saveKey:(NSString*)saveKey
																									expiration:(NSTimeInterval)expiration
																						policyParameters:(NSDictionary*)policyParameters {
	
	NSString* URLString = [NSString stringWithFormat:@"%@/%@", APIHost, bucket];
	
	NSString* policy = [self policyWithBucket:bucket
																		saveKey:saveKey
																 expiration:expiration
													 policyParameters:policyParameters];
	
	NSString* signature = [self policySignatureWithBucketSecret:bucketSecret
																											 policy:policy];
	
	NSDictionary* parameters = @{@"policy": policy,
															 @"signature": signature};
	
	void (^bodyBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
		NSError* fileError = nil;
		[formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath]
															 name:@"file"
													 fileName:[filePath lastPathComponent]
													 mimeType:@"multipart/form-data"
															error:&fileError];
	};
	
	NSMutableURLRequest* request = [super multipartFormRequestWithMethod:@"POST"
																														 URLString:URLString
																														parameters:parameters
																						 constructingBodyWithBlock:bodyBlock
																																 error:nil];
	return request;
}

@end
