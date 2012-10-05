//
//  UIColor+RZAdditions.h
//  RZNotificationView
//
//  Created by Sébastien HOUZE on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RZAdditions)

+ (UIColor *)lighterColorForColor:(UIColor *)c;
+ (UIColor *)lighterColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value;
+ (UIColor *)lighterColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlphaOffset:(CGFloat)alpha;
+ (UIColor *)lighterColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlpha:(CGFloat)alpha;


+ (UIColor *)darkerColorForColor:(UIColor *)c;
+ (UIColor *)darkerColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value;
+ (UIColor *)darkerColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlphaOffset:(CGFloat)alpha;
+ (UIColor *)darkerColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlpha:(CGFloat)alpha;

@end
