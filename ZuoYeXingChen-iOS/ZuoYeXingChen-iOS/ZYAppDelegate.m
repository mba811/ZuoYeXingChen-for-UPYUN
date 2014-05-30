//
//  ZYAppDelegate.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYAppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import "AFNetworking/AFNetworking.h"
#import "UIKit+AFNetworking/AFNetworkActivityIndicatorManager.h"


#ifdef DEBUG
#import "PonyDebugger.h"
#endif


static NSString* const WeiboAppKey = @"2174613361";
static NSString* const WeiboAppSecret = @"e68ff9fd6c1098c0f4ec8675ed99a7f4";
static NSString* const WeiboRedirectURI = @"https://api.weibo.com/oauth2/default.html";

static NSString* const AVOSCloudAppID = @"sk5arervzq4g6q3uz42cpxmaj1z2k45v2gzlss3wpzj936he";
static NSString* const AVOSCloudAppKey = @"fqq2p98fz3qxthxa1fya5s5jedjnjqq5t3i0hz3ccolbtrp8";


@implementation ZYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo
									 withAppKey:WeiboAppKey
								 andAppSecret:WeiboAppSecret
							 andRedirectURI:WeiboRedirectURI];
	
	[AVOSCloud setApplicationId:AVOSCloudAppID
										clientKey:AVOSCloudAppKey];
	
	[AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	[AVAnalytics setCrashReportEnabled:YES];
	
	[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	
	[[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
	}];
	
#ifdef DEBUG
	PDDebugger* debugger = [PDDebugger defaultInstance];
	[debugger connectToURL:[NSURL URLWithString:@"ws://192.168.0.100:9000/device"]];
	[debugger enableNetworkTrafficDebugging];
	[debugger forwardAllNetworkTraffic];
	[debugger enableViewHierarchyDebugging];
#endif
	
	self.window.backgroundColor = [UIColor whiteColor];
	[AVUser logOut];
	if (![AVUser currentUser]) {
		UIStoryboard* welcome = [UIStoryboard storyboardWithName:@"Welcome" bundle:nil];
		self.window.rootViewController = [welcome instantiateInitialViewController];
	} else {
		UIStoryboard* main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		self.window.rootViewController = [main instantiateInitialViewController];
	}
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
