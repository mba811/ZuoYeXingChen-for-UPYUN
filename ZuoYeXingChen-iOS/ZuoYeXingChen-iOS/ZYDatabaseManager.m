//
//  ZYXCDatabaseManager.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYDatabaseManager.h"
#import "ZYPhoto.h"
#import "YapDatabaseView.h"
#import "YapDatabaseConnection.h"


@interface ZYDatabaseManager ()

@end


@implementation ZYDatabaseManager

+ (ZYDatabaseManager*)defaultManager {
	static dispatch_once_t pred;
	static ZYDatabaseManager *instance = nil;
	dispatch_once(&pred, ^{instance = [[self alloc] initSingleton];});
	return instance;
}

- (id)initSingleton {
	NSFileManager* manager = [NSFileManager defaultManager];
	NSString* appSupportPath = [[manager URLForDirectory:NSApplicationSupportDirectory
																							inDomain:NSUserDomainMask
																		 appropriateForURL:nil
																								create:YES
																								 error:nil] path];
	NSString *targetPath = [appSupportPath stringByAppendingPathComponent:@"ZYXC.sqlite"];
	
	self = [super initWithPath:targetPath];
	if (self) {
		[self registerPhotosDatabaseView];
	}
	
	return self;
}

- (NSString*)formatMonthOrDay:(NSInteger)number {
	NSString* numberString;
	if (number >= 10) {
		numberString = [NSString stringWithFormat:@"%ld", (long)number];
	} else {
		numberString = [NSString stringWithFormat:@"0%ld", (long)number];
	}
	return numberString;
}

- (void)registerPhotosDatabaseView {
	YapDatabaseViewBlockType groupingBlockType;
	YapDatabaseViewGroupingWithObjectBlock groupingBlock;
	
	YapDatabaseViewBlockType sortingBlockType;
	YapDatabaseViewSortingWithObjectBlock sortingBlock;
	
	groupingBlockType = YapDatabaseViewBlockTypeWithObject;
	groupingBlock = ^NSString *(NSString *collection, NSString *key, id object) {
		if (![object isKindOfClass:[ZYPhoto class]]) {
    	return nil;
		}
		
		ZYPhoto* photo = (ZYPhoto*)object;
		
		NSCalendarUnit unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
		NSDateComponents *components =
		[[NSCalendar currentCalendar] components:unitFlags fromDate:photo.date];
		NSInteger year = [components year];
		NSInteger month = [components month];
		NSInteger day = [components day];
		NSString* monthString = [self formatMonthOrDay:month];
		NSString* dayString = [self formatMonthOrDay:day];
		NSString* groupKey = [NSString stringWithFormat:@"%ld%@%@", (long)year, monthString, dayString];
		
		// NSLog(@"groupKey: %@, date: %@", groupKey, photo.date);
		
		return groupKey;
	};
	
	NSComparisonResult (^comparePhoto)(ZYPhoto*, ZYPhoto*) = ^NSComparisonResult(ZYPhoto* photo1, ZYPhoto* photo2) {
		return [photo1.date compare:photo2.date];
	};
	
	sortingBlockType = YapDatabaseViewBlockTypeWithObject;
	sortingBlock = ^NSComparisonResult (NSString *group,
																			NSString *collection1, NSString *key1, id obj1,
																			NSString *collection2, NSString *key2, id obj2) {
		return comparePhoto(obj1, obj2);
	};
	
	YapDatabaseView *databaseView =
	[[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
															 groupingBlockType:groupingBlockType
																		sortingBlock:sortingBlock
																sortingBlockType:sortingBlockType];
	
	[self registerExtension:databaseView withName:ZYXCDatabaseViewPhotos];
}

@end
