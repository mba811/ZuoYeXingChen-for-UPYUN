//
//  UpYunManager.h
//  iOS-SDK-for-UPYUN
//
//  Created by tao on 5/2/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "AFNetworking.h"
@import AssetsLibrary;


static NSString* const APIHost_Auto = @"http://v0.api.upyun.com";
static NSString* const APIHost_TELECOM = @"http://v1.api.upyun.com";
static NSString* const APIHost_CNC = @"http://v2.api.upyun.com";
static NSString* const APIHost_CTT = @"http://v3.api.upyun.com";


@interface UpYunHttpFromClient : AFHTTPRequestOperationManager

@property (nonatomic, assign) NSTimeInterval expiration;

// 可以设置一些对于当前bucket是全局的policy参数
@property (nonatomic, copy) NSMutableDictionary* policyParameters;


- (instancetype)initWithUpYunAPIHost:(NSString*)APIHost
															bucket:(NSString*)bucket
												bucketSecret:(NSString*)bucketSecret;

- (void)uploadImageWithALAsset:(ALAsset*)asset
											 saveKey:(NSString*)saveKey
											 success:(void (^)(id responseObject))success
											 failure:(void (^)(NSError *error, id responseObject))failure;

- (void)uploadImageWithALAsset:(ALAsset*)asset
											 saveKey:(NSString*)saveKey
											progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
											 success:(void (^)(id responseObject))success
											 failure:(void (^)(NSError *error, id responseObject))failure;

- (void)uploadFileWithPath:(NSString *)path
									 saveKey:(NSString *)saveKey
									 success:(void (^)(id responseObject))success
									 failure:(void (^)(NSError *error, id responseObject))failure;

- (void)uploadFileWithPath:(NSString *)path
									 saveKey:(NSString *)saveKey
									progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
									 success:(void (^)(id responseObject))success
									 failure:(void (^)(NSError *error, id responseObject))failure;

- (void)uploadFileWithPath:(NSString *)path
									 saveKey:(NSString *)saveKey
					policyParameters:(NSDictionary *)policyParameters
									progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
									 success:(void (^)(id responseObject))success
									 failure:(void (^)(NSError *error, id responseObject))failure;

@end
