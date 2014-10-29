//
//  CustomLabel.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 02/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (CGFloat) resizeForWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    [self sizeToFit];
    return self.frame.size.height + 5.0f;
}

- (BOOL) shouldHandleTouch {
    return YES;
}

@end
