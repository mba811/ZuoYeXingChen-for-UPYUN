//
//  ZYXCDatabaseManager.h
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "YapDatabase/YapDatabase.h"


static NSString* const ZYXCCollectionPhotoGroups = @"ZYXCCollectionPhotoGroups";
static NSString* const ZYXCDatabaseViewPhotoGroups = @"ZYXCDatabaseViewPhotoGroups";
static NSString* const ZYXCDatabaseGroupPhotoGroups = @"ZYXCDatabaseGroupPhotoGroups";

static NSString* const ZYXCCollectionPhotos = @"ZYXCCollectionPhotos";
static NSString* const ZYXCDatabaseViewPhotos = @"ZYXCDatabaseViewPhotos";


@interface ZYDatabaseManager : YapDatabase

+ (ZYDatabaseManager*)defaultManager;

@end
