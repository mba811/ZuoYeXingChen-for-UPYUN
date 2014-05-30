//
//  UpYunManager.m
//  iOS-SDK-for-UPYUN
//
//  Created by tao on 5/2/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "UpYunHttpFromClient.h"
#import "UpYunRequestSerializer.h"


@interface UpYunHttpFromClient ()

@property (nonatomic, strong) NSString* APIHost;
@property (nonatomic, copy) NSString* bucket;
@property (nonatomic, copy) NSString* bucketSecret;

@end


@implementation UpYunHttpFromClient

- (instancetype)initWithUpYunAPIHost:(NSString*)APIHost
															bucket:(NSString*)bucket
												bucketSecret:(NSString*)bucketSecret {
	NSString* baseURLString = [NSString stringWithFormat:@"%@/%@", APIHost, bucket];
	NSURL* baseURL = [NSURL URLWithString:baseURLString];
	self = [super initWithBaseURL:baseURL];
	if (self) {
		self.APIHost = APIHost;
		self.bucket = bucket;
		self.bucketSecret = bucketSecret;
		self.expiration = 600; // default
		self.policyParameters = [NSMutableDictionary new];
		
		self.requestSerializer = [UpYunRequestSerializer serializer];
		self.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	
	return self;
}

- (void)uploadImageWithALAsset:(ALAsset*)asset
											 saveKey:(NSString*)saveKey
											 success:(void (^)(id responseObject))success
											 failure:(void (^)(NSError *error, id responseObject))failure {
	[self uploadImageWithALAsset:asset
											 saveKey:saveKey
							policyParameters:nil
											progress:nil
											 success:success
											 failure:failure];
}

- (void)uploadImageWithALAsset:(ALAsset*)asset
											 saveKey:(NSString*)saveKey
											progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
											 success:(void (^)(id responseObject))success
											 failure:(void (^)(NSError *error, id responseObject))failure {
	[self uploadImageWithALAsset:asset
											 saveKey:saveKey
							policyParameters:nil
											progress:progress
											 success:success
											 failure:failure];
}

- (void)uploadImageWithALAsset:(ALAsset*)asset
											 saveKey:(NSString*)saveKey
							policyParameters:(NSDictionary *)policyParameters
											progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
											 success:(void (^)(id responseObject))success
											 failure:(void (^)(NSError *error, id responseObject))failure {

	NSMutableURLRequest *request;
	
	if (policyParameters) {
		[self.policyParameters addEntriesFromDictionary:policyParameters];
	}
	
	CGImageRef imgRef = [[asset defaultRepresentation] fullResolutionImage];
	NSData* fileData = UIImageJPEGRepresentation([UIImage imageWithCGImage:imgRef], 1.0f);
	
	UpYunRequestSerializer* requestSerializer = (UpYunRequestSerializer*)self.requestSerializer;
	request = [requestSerializer multipartFormRequestWithUpYunAPIHost:self.APIHost
																														 bucket:self.bucket
																											 bucketSecret:self.bucketSecret
																													 fileData:fileData
																														saveKey:saveKey
																												 expiration:self.expiration
																									 policyParameters:self.policyParameters];
	
	AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
		
		if (!success) {
			return ;
		}
		
		if (!responseObject) {
			success(nil);
			return ;
		}
		
		if ([responseObject isKindOfClass:[NSData class]]) {
			NSError* jsonError = nil;
			NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&jsonError];
			if (!jsonError) {
				success(jsonDict);
				return ;
			}
		}
		
		success(responseObject);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		if (!failure) {
			return ;
		}
		
		id responseObject = operation.responseObject;
		if (!responseObject) {
			failure(error, nil);
			return ;
		}
		
		if ([responseObject isKindOfClass:[NSData class]]) {
			NSError* jsonError = nil;
			NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&jsonError];
			if (!jsonError) {
				failure(error, jsonDict);
				return ;
			}
		}
		
		failure(error, responseObject);
		
	}];
	
	if (progress) {
		[requestOperation setUploadProgressBlock:progress];
	}
	
	[self.operationQueue addOperation:requestOperation];
}

- (void)uploadFileWithPath:(NSString *)path
									 saveKey:(NSString *)saveKey
									 success:(void (^)(id responseObject))success
									 failure:(void (^)(NSError *error, id responseObject))failure {
	
	[self uploadFileWithPath:path
									 saveKey:saveKey
					policyParameters:nil
									progress:nil
									 success:success
									 failure:failure];
}

- (void)uploadFileWithPath:(NSString *)path
									 saveKey:(NSString *)saveKey
									progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
									 success:(void (^)(id responseObject))success
									 failure:(void (^)(NSError *error, id responseObject))failure {
	
	[self uploadFileWithPath:path
									 saveKey:saveKey
					policyParameters:nil
									progress:progress
									 success:success
									 failure:failure];
}

- (void)uploadFileWithPath:(NSString *)path
									 saveKey:(NSString *)saveKey
					policyParameters:(NSDictionary *)policyParameters
									progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
									 success:(void (^)(id responseObject))success
									 failure:(void (^)(NSError *error, id responseObject))failure {
	
	NSMutableURLRequest *request;
	
	if (policyParameters) {
		[self.policyParameters addEntriesFromDictionary:policyParameters];
	}
	
	UpYunRequestSerializer* requestSerializer = (UpYunRequestSerializer*)self.requestSerializer;
	request = [requestSerializer multipartFormRequestWithUpYunAPIHost:self.APIHost
																														 bucket:self.bucket
																											 bucketSecret:self.bucketSecret
																													 filePath:path
																														saveKey:saveKey
																												 expiration:self.expiration
																									 policyParameters:self.policyParameters];
	
	AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
		
		if (!success) {
			return ;
		}
		
		if (!responseObject) {
			success(nil);
			return ;
		}
		
		if ([responseObject isKindOfClass:[NSData class]]) {
			NSError* jsonError = nil;
			NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&jsonError];
			if (!jsonError) {
				success(jsonDict);
				return ;
			}
		}
		
		success(responseObject);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {

		if (!failure) {
			return ;
		}
		
		id responseObject = operation.responseObject;
		if (!responseObject) {
			failure(error, nil);
			return ;
		}
		
		if ([responseObject isKindOfClass:[NSData class]]) {
			NSError* jsonError = nil;
			NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&jsonError];
			if (!jsonError) {
				failure(error, jsonDict);
				return ;
			}
		}
		
		failure(error, responseObject);
		
	}];
	
	if (progress) {
		[requestOperation setUploadProgressBlock:progress];
	}
	
	[self.operationQueue addOperation:requestOperation];
}

@end
