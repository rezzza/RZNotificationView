//
//  UIView+Frame.h
//  RZNotificationView
//
//  Created by Marian Paul on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

- (void) setOrigin:(CGPoint)origin;
- (void) setXOrigin:(CGFloat)xOrigin;
- (void) setYOrigin:(CGFloat)yOrigin;
- (void) setWidth:(CGFloat)width;
- (void) setHeight:(CGFloat)height;
- (void) setSize:(CGSize)size;


@end
