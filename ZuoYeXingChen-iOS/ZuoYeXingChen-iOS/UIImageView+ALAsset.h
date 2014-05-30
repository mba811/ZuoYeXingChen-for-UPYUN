//
//  UIImageView+ALAsset.h
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

@import AssetsLibrary;


@interface UIImageView (ALAsset)

- (void)setImageWithAsset:(ALAsset*)asset;
- (void)setImageWithAssetURL:(NSURL*)assetURL;

@end
