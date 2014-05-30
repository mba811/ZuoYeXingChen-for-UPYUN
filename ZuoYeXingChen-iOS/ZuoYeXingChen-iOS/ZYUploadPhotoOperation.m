//
//  ZYXCUploadPhotoOperation.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/28/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYUploadPhotoOperation.h"


@interface ZYUploadPhotoOperation ()

@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;

@property (nonatomic, copy) NSString* directory;
@property (nonatomic, strong) UpYunHttpFromClient* upYunClient;
@property (nonatomic, strong) ZYPhoto* photo;

@property (nonatomic, strong) ZYXCUploadPhotoSuccessBlock successBlock;

@end


@implementation ZYUploadPhotoOperation

- (instancetype)initWithUpYunClient:(UpYunHttpFromClient*)upYunClient
															photo:(ZYPhoto*)photo
													directory:(NSString*)directory
														success:(ZYXCUploadPhotoSuccessBlock)success {
	self = [super init];
	if (self) {
		_executing = NO;
		_finished = NO;
		
		_upYunClient = upYunClient;
		_photo = photo;
		_directory = directory;
		_successBlock = success;
	}
	return self;
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return _executing;
}

- (BOOL)isFinished {
	return _finished;
}

- (void)start {
	if ([self isCancelled]) {
		[self willChangeValueForKey:@"isFinished"];
		_finished = YES;
		[self didChangeValueForKey:@"isFinished"];
		return;
	}
	
	[self willChangeValueForKey:@"isExecuting"];
	[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
	_executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
	void (^progressBlock)(NSUInteger, long long, long long) = ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		if (totalBytesExpectedToWrite > 0) {
			CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
			NSLog(@"%f %lld %lld", progress, totalBytesWritten, totalBytesExpectedToWrite);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ZYXCUploadProgressChanged" object:nil userInfo:@{@"kPhotoMD5": self.photo.md5, @"kProgress": @(progress)}];
		}
	};
	
	NSString* saveKey = [NSString stringWithFormat:@"/%@/%@.jpg", self.directory, self.photo.md5];
	NSLog(@"saveKey: %@", saveKey);
	
	[self.upYunClient uploadImageWithALAsset:self.photo.asset
																	 saveKey:saveKey
																	progress:progressBlock
																	 success:^(id responseObject) {
																		 NSLog(@"success: %@", responseObject);
																		 [self finishWithError:nil];
																	 } failure:^(NSError *error, id responseObject) {
																		 NSLog(@"failure: %@ %@", error, responseObject);
																		 [self finishWithError:error];
																	 }];
}

- (void)finishWithError:(NSError*)error {
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	
	_executing = NO;
	_finished = YES;
	
	if (!error) {
		self.successBlock();
	}
	
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

@end
