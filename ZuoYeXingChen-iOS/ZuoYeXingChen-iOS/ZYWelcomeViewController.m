//
//  ZYXCWelcomeViewController.m
//  ZuoYeXingChen-iOS
//
//  Created by tao on 5/27/14.
//  Copyright (c) 2014 TaoZhou. All rights reserved.
//

#import "ZYWelcomeViewController.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import <AVOSCloudSNS/AVUser+SNS.h>


@interface ZYWelcomeViewController ()

@end


@implementation ZYWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginThroughWeibo:(id)sender {	
	[AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
		if (error) {
			NSLog(@"loginThroughWeibo failed: %@", error);
			return ;
		}

		[AVUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
			if (error) {
				NSLog(@"loginWithAuthData failed: %@", error);
				return ;
			}
			
			NSLog(@"loginWithAuthData success: %@", user);
			
			UIStoryboard* main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			self.view.window.rootViewController = [main instantiateInitialViewController];
		}];
	} toPlatform:AVOSCloudSNSSinaWeibo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
