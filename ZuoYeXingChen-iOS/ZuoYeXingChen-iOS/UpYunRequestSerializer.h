//
//  UpYunRequestSerializer.h
//  iOS-SDK-for-UPYUN
//
//  Created by tao on 5/2/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "AFNetworking.h"

@interface UpYunRequestSerializer : AFHTTPRequestSerializer

- (NSMutableURLRequest*)multipartFormRequestWithUpYunAPIHost:(NSString*)APIHost
																											bucket:(NSString*)bucket
																								bucketSecret:(NSString*)bucketSecret
																										fileData:(NSData*)fileData
																										 saveKey:(NSString*)saveKey
																									expiration:(NSTimeInterval)expiration
																						policyParameters:(NSDictionary*)policyParameters;

- (NSMutableURLRequest*)multipartFormRequestWithUpYunAPIHost:(NSString*)APIHost
																											bucket:(NSString*)bucket
																								bucketSecret:(NSString*)bucketSecret
																										filePath:(NSString*)filePath
																										 saveKey:(NSString*)saveKey
																									expiration:(NSTimeInterval)expiration
																						policyParameters:(NSDictionary*)policyParameters;

@end
