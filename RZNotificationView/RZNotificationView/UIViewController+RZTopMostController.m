//
//  UIViewController+RZTopMostController.m
//  RZNotificationView
//
//  Created by Marian Paul on 06/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "UIViewController+RZTopMostController.h"
#import "UITabBarController+RZTopMostControllerProtocol.h"
#import "UINavigationController+RZTopMostControllerProtocol.h"

@implementation UIViewController (RZTopMostController)

+ (UIViewController*) getModalViewControllerOfControllerIfExists:(UIViewController*)controller
{
    UIViewController *toReturn = nil;
    // modalViewController is deprecated since iOS 6
    if ([controller respondsToSelector:@selector(presentedViewController)])
        toReturn = [controller performSelector:@selector(presentedViewController)];
    else
        toReturn = [controller performSelector:@selector(modalViewController)];
    
    // if no modal view controller, return the controller itself
    if (!toReturn) toReturn = controller;
    return toReturn;
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = ((UIWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0]).rootViewController;
    
    topController = [self getModalViewControllerOfControllerIfExists:topController];
    
    while ([topController conformsToProtocol:@protocol(RZTopMostControllerProtocol)])
    {
        topController = [(UIViewController <RZTopMostControllerProtocol> *)topController visibleViewController];
        topController = [self getModalViewControllerOfControllerIfExists:topController];
    }
    return topController;
}

@end
