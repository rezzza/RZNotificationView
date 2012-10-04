//
//  AppDelegate.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "AppDelegate.h"
#import "SampleViewController.h"
#import "SimpleSampleViewController.h"

#import "OtherViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    SampleViewController *s = [[SampleViewController alloc] initWithNibName:@"SampleViewController" bundle:nil];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:s];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Custom" image:nil tag:0];
    n.tabBarItem = tabBarItem;
    
    SimpleSampleViewController *simple = [[SimpleSampleViewController alloc] initWithNibName:@"SimpleSampleViewController" bundle:nil];
    UINavigationController *nSimple = [[UINavigationController alloc] initWithRootViewController:simple];
    tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Easy" image:nil tag:0];
    nSimple.tabBarItem = tabBarItem;
    
    self.tabBarController = [[UITabBarController alloc] init];
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:n, nSimple, nil]];
    
    [self.window setRootViewController:self.tabBarController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"%@", url.query);
    if ([[url host] isEqualToString:@"OtherViewController"]) {
        OtherViewController *s = [[OtherViewController alloc] initWithNibName:@"OtherViewController" bundle:nil];
        UINavigationController *n = (UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:0];
        [n pushViewController:s animated:YES];
        s.message.text = [url.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
