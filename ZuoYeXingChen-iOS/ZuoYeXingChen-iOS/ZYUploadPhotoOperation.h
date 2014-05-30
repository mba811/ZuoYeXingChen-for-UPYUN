//
//  ZYXCUploadPhotoOperation.h
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/28/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYPhoto.h"
#import "UpYunHttpFromClient.h"


typedef void (^ZYXCUploadPhotoSuccessBlock)(void);


@interface ZYUploadPhotoOperation : NSOperation

- (instancetype)initWithUpYunClient:(UpYunHttpFromClient*)upYunClient
															photo:(ZYPhoto*)photo
													directory:(NSString*)directory
														success:(ZYXCUploadPhotoSuccessBlock)success;

@end
