//
//  ZYXCViewController.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYViewController.h"
#import "ZYPhotoCollectionViewHeader.h"
#import "ZYPhotoCollectionViewCell.h"
#import "UIImage+MD5.h"
#import "ZYPhoto.h"
#import "ZYDatabaseManager.h"
#import "ZYNetworkManager.h"
#import "ZYUploadPhotoOperation.h"
#import "UpYunHttpFromClient.h"
#import "YapDatabaseConnection.h"
#import "YapDatabaseViewChange.h"
#import "YapDatabaseViewMappings.h"
#import "YapDatabaseViewConnection.h"
#import "YapDatabaseViewTransaction.h"
#import "SDImageCache.h"
#import <AVOSCloud/AVOSCloud.h>
@import AssetsLibrary;
@import CoreLocation;


static NSString* const Bucket = @"zuoyexingchen";
static NSString* const BucketSecret = @"61g5MnhZi/mRvjkJhvPwX7efSYU=";

static NSString* const kPhotoCellReuseIdentifier = @"PhotoCellReuseIdentifier";
static NSString* const kPhotoHeaderReuseIdentifier = @"PhotoHeaderReuseIdentifier";


@interface ZYViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) ALAssetsLibrary* library;

@property (nonatomic, strong) YapDatabaseConnection* readConnection;
@property (nonatomic, strong) YapDatabaseConnection* writeConnection;
@property (nonatomic, strong) YapDatabaseViewMappings* photosMappings;

@property (nonatomic, strong) UpYunHttpFromClient* upYunClient;

@property (nonatomic, strong) NSMutableArray* uploadPhotosQueue;
@property (nonatomic, strong) NSOperationQueue* uploadOperationQueue;

@end


@implementation ZYViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.title = @"昨夜星辰";
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
	layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 44);
	layout.itemSize = CGSizeMake(104, 104);
	layout.minimumLineSpacing = 4.0f;
	layout.minimumInteritemSpacing = 4.0f;
	self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	[self.view addSubview:self.collectionView];
	
	[self.collectionView registerClass:[ZYPhotoCollectionViewCell class] forCellWithReuseIdentifier:kPhotoCellReuseIdentifier];
	[self.collectionView registerClass:[ZYPhotoCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kPhotoHeaderReuseIdentifier];
	
	self.library = [ALAssetsLibrary new];
	
	self.upYunClient = [[UpYunHttpFromClient alloc] initWithUpYunAPIHost:APIHost_Auto
																																bucket:Bucket
																													bucketSecret:BucketSecret];
	
	NSDictionary* policyParamerters = @{@"notify-url": @"http://zyxc.avosapps.com/upload-photo-success"};
	[self.upYunClient.policyParameters addEntriesFromDictionary:policyParamerters];
	
	self.uploadPhotosQueue = [NSMutableArray new];
	
	NSOperationQueue* q = [NSOperationQueue new];
	[q setMaxConcurrentOperationCount:1];
	self.uploadOperationQueue = q;
	
	[self initDatabase];
	
	[self getUploadPhotos];
	
	[self findSavedPhotos];
}

- (void)initDatabase {
	ZYDatabaseManager* manager = [ZYDatabaseManager defaultManager];
	self.readConnection = [manager newConnection];
	self.writeConnection = [manager newConnection];
	
	[self.readConnection beginLongLivedReadTransaction];
	
	[self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
		NSComparisonResult (^compareGroup)(NSString*, NSString*) = ^NSComparisonResult(NSString* s1, NSString* s2) {
			return [s1 compare:s2 options:NSNumericSearch];
		};
		
		NSArray* groups = [[[transaction ext:ZYXCDatabaseViewPhotos] allGroups] sortedArrayUsingComparator:compareGroup];
		
		self.photosMappings = [[YapDatabaseViewMappings alloc] initWithGroups:groups view:ZYXCDatabaseViewPhotos];
		[self.photosMappings updateWithTransaction:transaction];
	}];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(yapDatabaseModified:)
																							 name:YapDatabaseModifiedNotification
																						 object:self.readConnection.database];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
																									name:YapDatabaseModifiedNotification
																								object:_readConnection.database];
	
	[_uploadOperationQueue cancelAllOperations];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.collectionView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
}

- (void)getUploadPhotos {
	NSString* directory = [AVUser currentUser].username;
	
	[[ZYNetworkManager defaultManager] getUploadedPhotosWithDirectory:directory success:^(id responseObject) {
		NSLog(@"getUploadPhotos success: %@", responseObject);
		
		NSDictionary* photos = responseObject[@"photos"];
		if (photos) {
			for (NSString* photoMd5 in photos) {
				[self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *writeTransaction) {
					ZYPhoto* photo = [writeTransaction objectForKey:photoMd5 inCollection:ZYXCCollectionPhotos];
					photo.state = ZYPhotoStateUploaded;
					[writeTransaction setObject:photo
															 forKey:photoMd5
												 inCollection:ZYXCCollectionPhotos];
				}];
			}
		}
		
		[self getUploadPhotos];
		
	} failure:^(NSError *error) {
		NSLog(@"getUploadPhotos failed: %@", error);
		
		[self getUploadPhotos];
	}];
}

- (void)yapDatabaseModified:(NSNotification*)notification {
	NSArray* notifications = [self.readConnection beginLongLivedReadTransaction];
	if (![notifications count]) {
		return ;
	}
	
	[self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
		
		NSComparisonResult (^compareGroup)(NSString*, NSString*) = ^NSComparisonResult(NSString* s1, NSString* s2) {
			return [s1 compare:s2 options:NSNumericSearch];
		};
		
		NSArray* groups = [[[transaction ext:ZYXCDatabaseViewPhotos] allGroups] sortedArrayUsingComparator:compareGroup];
		
		NSLog(@"yapDatabaseModified, group count: %lu", (unsigned long)[groups count]);
		
		self.photosMappings = [[YapDatabaseViewMappings alloc] initWithGroups:groups view:ZYXCDatabaseViewPhotos];
		[self.photosMappings setIsDynamicSectionForAllGroups:YES];
		[self.photosMappings updateWithTransaction:transaction];
	}];
	
	[self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return [[self.photosMappings allGroups] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.photosMappings numberOfItemsInSection:section];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
					 viewForSupplementaryElementOfKind:(NSString *)kind
																 atIndexPath:(NSIndexPath *)indexPath {
	
	ZYPhotoCollectionViewHeader* header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kPhotoHeaderReuseIdentifier forIndexPath:indexPath];
	
	NSString* groupName = [self.photosMappings groupForSection:indexPath.section];
	
	__block NSDate* date = nil;
	
	[self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
    ZYPhoto* photo = [[transaction ext:ZYXCDatabaseViewPhotos] objectAtIndex:0 inGroup:groupName];
		date = photo.date;
	}];
	
	header.date = date;
	
	return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	ZYPhotoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReuseIdentifier forIndexPath:indexPath];
	
	NSInteger section = indexPath.section;
	NSInteger item = indexPath.item;
	
	NSString* groupName = [self.photosMappings groupForSection:section];
	
	__block ZYPhoto* photo = nil;
	
	[self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
    photo = [[transaction ext:ZYXCDatabaseViewPhotos] objectAtIndex:item inGroup:groupName];
	}];
	
	[cell setPhoto:photo];
	
	return cell;
}

- (void)findSavedPhotos {
	void (^enumerationBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup *group, BOOL *stop) {
		if (group) {
			NSString* title = [group valueForProperty: ALAssetsGroupPropertyName];
			NSLog(@"findSavedPhotos: %@ %@", title, group);
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[self enumeratePhotosInAssetsGroup:group];
			});
			
		}
	};
	
	void (^failureBlock)(NSError*) = ^(NSError* error) {
		NSLog(@"findSavedPhotos: %@", error);
	};
	
	[self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
															usingBlock:enumerationBlock
														failureBlock:failureBlock];
}

- (void)enumeratePhotosInAssetsGroup:(ALAssetsGroup*)group {
	[group enumerateAssetsUsingBlock:^(ALAsset *photoAsset, NSUInteger index, BOOL *stop) {
		if (!photoAsset) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[self uploadPhotos];
			});
			return ;
		}
		
		NSString* fileName = [photoAsset defaultRepresentation].filename;
		NSLog(@"enumeratePhotosInAssetsGroup: %lu, %@, %@", (unsigned long)index, fileName, photoAsset);
		
		UIImage* image = [UIImage imageWithCGImage:photoAsset.thumbnail];
		
		NSURL* assetURL = [photoAsset defaultRepresentation].url;
		[[SDImageCache sharedImageCache] storeImage:image forKey:[assetURL absoluteString]];
		
		NSString* md5 = [image md5];
		
		__block BOOL exists = FALSE;
		
		[self.readConnection readWithBlock:^(YapDatabaseReadTransaction *readTransaction) {
			ZYPhoto* photo = [readTransaction objectForKey:md5
																	 inCollection:ZYXCCollectionPhotos];
			if (photo) {
				exists = TRUE;
				if (photo.state == ZYPhotoStateLocal) {
					photo.asset = photoAsset;
					[self.uploadPhotosQueue addObject:photo];
				}
			}
		}];
		
		if (!exists) {
			NSDate* date = [photoAsset valueForProperty:ALAssetPropertyDate];
			ZYPhoto* photo = [[ZYPhoto alloc] initWithMd5:md5
																									 date:date
																									state:ZYPhotoStateLocal];
			photo.assetURL = assetURL;
			photo.asset = photoAsset;
			[self.uploadPhotosQueue addObject:photo];
			
			[self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *writeTransaction) {
				[writeTransaction setObject:photo
														 forKey:md5
											 inCollection:ZYXCCollectionPhotos];
			}];
		}
	}];
}

- (void)uploadPhotos {
	
	NSString* directory = [AVUser currentUser].username;
	if (!directory) {
		NSLog(@"directory is null");
		return ;
	}
	
	while ([self.uploadPhotosQueue count] > 0) {
		
    ZYPhoto* photo = [self.uploadPhotosQueue firstObject];
		
		ZYUploadPhotoOperation* operation = [[ZYUploadPhotoOperation alloc] initWithUpYunClient:self.upYunClient photo:photo directory:directory success:^{
			NSLog(@"upload %@.jpg completed", photo.md5);
			[self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *writeTransaction) {
				photo.state = ZYPhotoStateWaitServerReply;
				[writeTransaction setObject:photo
														 forKey:photo.md5
											 inCollection:ZYXCCollectionPhotos];
			}];
		}];
		
		[self.uploadOperationQueue addOperation:operation];
		[self.uploadPhotosQueue removeObjectAtIndex:0];
	}

}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
