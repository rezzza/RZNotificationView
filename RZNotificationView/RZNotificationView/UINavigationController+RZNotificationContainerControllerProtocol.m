//
//  UINavigationController+RZNotificationContainerControllerProtocol.m
//  RZNotificationView
//
//  Created by Marian Paul on 05/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "UINavigationController+RZNotificationContainerControllerProtocol.h"

@implementation UINavigationController (RZNotificationContainerControllerProtocol)
- (UIViewController *)visibleViewController
{
    return self.topViewController;
}
@end
