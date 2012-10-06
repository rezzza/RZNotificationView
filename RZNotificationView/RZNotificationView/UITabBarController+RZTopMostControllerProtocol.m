//
//  UITabBarController+RZNotificationContainerControllerProtocol.m
//  RZNotificationView
//
//  Created by Marian Paul on 05/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "UITabBarController+RZTopMostControllerProtocol.h"

@implementation UITabBarController (RZTopMostControllerProtocol)
- (UIViewController*)visibleViewController
{
    return self.selectedViewController;
}
@end
