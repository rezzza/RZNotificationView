//
//  UIView+Frame.m
//  RZNotificationView
//
//  Created by Marian Paul on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void) setOrigin:(CGPoint)origin
{
    CGRect newFrame = self.frame;
    newFrame.origin = origin;
    self.frame = newFrame;
}

- (void) setXOrigin:(CGFloat)xOrigin
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = xOrigin;
    self.frame = newFrame;
}

- (void) setYOrigin:(CGFloat)yOrigin
{
    CGRect newFrame = self.frame;
    newFrame.origin.y = yOrigin;
    self.frame = newFrame;
}

- (void) setWidth:(CGFloat)width
{
    CGRect newFrame = self.frame;
    newFrame.size.width = width;
    self.frame = newFrame;
}

- (void) setHeight:(CGFloat)height
{
    CGRect newFrame = self.frame;
    newFrame.size.height = height;
    self.frame = newFrame;
}

- (void) setSize:(CGSize)size
{
    CGRect newFrame = self.frame;
    newFrame.size = size;
    self.frame = newFrame;
}

@end
