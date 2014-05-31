//
//  ZYXCPhoto.h
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

@import AssetsLibrary;


typedef enum {
	ZYPhotoStateLocal,
	ZYPhotoStateWaitServerReply,
	ZYPhotoStateUploaded,
	ZYPhotoStateNotAvailable
} ZYPhotoState;


@interface ZYPhoto : NSObject

- (id)initWithMd5:(NSString*)md5
						 date:(NSDate*)date
						state:(ZYPhotoState)state;

@property (nonatomic, copy) NSString* md5;
@property (nonatomic, copy) NSURL* thumbnailURL;
@property (nonatomic, copy) NSDate* date;
@property (nonatomic, assign) ZYPhotoState state;
@property (nonatomic, copy) NSURL* assetURL;
@property (nonatomic, strong) ALAsset* asset; // only for cache purpose

@end
