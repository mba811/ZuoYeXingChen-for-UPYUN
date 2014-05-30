//
//  UIImageView+ALAsset.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "UIImageView+ALAsset.h"
#import "SDImageCache.h"


@implementation UIImageView (ALAsset)

- (void)setImageWithAsset:(ALAsset*)asset {
	
	SDImageCache* cache = [SDImageCache sharedImageCache];
	
  NSString* key =	[[asset defaultRepresentation].url absoluteString];
	
	UIImage* image = [cache imageFromMemoryCacheForKey:key];
	if (!image) {
		image = [UIImage imageWithCGImage:asset.thumbnail];
		[cache storeImage:image forKey:key];
	}
	
	self.image = image;
}

- (void)setImageWithAssetURL:(NSURL*)assetURL {
	
	SDImageCache* cache = [SDImageCache sharedImageCache];
	
	UIImage* image = [cache imageFromMemoryCacheForKey:[assetURL absoluteString]];
	if (image) {
		self.image = image;
		return ;
	}
	
	ALAssetsLibrary* library = [ALAssetsLibrary new];
	
	[library assetForURL:assetURL
					 resultBlock:^(ALAsset *asset) {
						 
						 NSURL* now = [asset defaultRepresentation].url;
						 
						 CGImageRef imgeRef = [asset thumbnail];
						 UIImage* image = [UIImage imageWithCGImage:imgeRef];
						 [cache storeImage:image forKey:[now absoluteString]];
						 
						 if (![assetURL isEqual:now]) {
							 return ;
						 }
						 
						 dispatch_async(dispatch_get_main_queue(), ^{
							 self.image = image;
						 });
					 }
	 
					failureBlock:^(NSError *error) {
						NSLog(@"assetForURL: %@", error);
						self.image = nil;
					}];
}

@end
