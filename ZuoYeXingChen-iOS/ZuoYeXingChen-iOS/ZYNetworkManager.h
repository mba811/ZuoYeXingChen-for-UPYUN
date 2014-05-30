//
//  ZYXCNetworkManager.h
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/20/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"


@interface ZYNetworkManager : AFHTTPRequestOperationManager

+ (ZYNetworkManager*)defaultManager;

@end
