//
//  UIColor+RZAdditions.m
//  RZNotificationView
//
//  Created by Sébastien HOUZE on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "UIColor+RZAdditions.h"

@implementation UIColor (RZAdditions)

// From BButton
+ (UIColor *)lighterColorForColor:(UIColor *)c
{
    return [UIColor lighterColorForColor:c withRgbOffset:0.6f];
}

+ (UIColor *)lighterColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value
{
    return [UIColor lighterColorForColor:oldColor withRgbOffset:value andAlphaOffset:0.0];
}

+ (UIColor *)lighterColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlpha:(CGFloat)alpha
{
    CGFloat alphaOffset = 0.0;
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    if (isGreyscale)
        alphaOffset = oldComponents[1] > alpha ? oldComponents[1] - alpha : alpha - oldComponents[1];
    else
        alphaOffset = oldComponents[3] > alpha ? oldComponents[3] - alpha : alpha - oldComponents[3];
    
    return [UIColor lighterColorForColor:oldColor withRgbOffset:value andAlphaOffset:alphaOffset];
}

+ (UIColor *)lighterColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlphaOffset:(CGFloat)alpha
{
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[1] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[2] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[3] = oldComponents[1]-alpha < 0.0 ? 0.0 : oldComponents[1]-alpha;
    } else {
        newComponents[0] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[1] = oldComponents[1]+value > 1.0 ? 1.0 : oldComponents[1]+value;
        newComponents[2] = oldComponents[2]+value > 1.0 ? 1.0 : oldComponents[2]+value;
        newComponents[3] = oldComponents[3]-alpha < 0.0 ? 0.0 : oldComponents[3]-alpha;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}

+ (UIColor *)darkerColorForColor:(UIColor *)c
{
    return [UIColor darkerColorForColor:c withRgbOffset:0.3f];
}

+ (UIColor *)darkerColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value
{
    return [UIColor darkerColorForColor:oldColor withRgbOffset:value andAlphaOffset:0.0];
}

+ (UIColor *)darkerColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlpha:(CGFloat)alpha
{
    CGFloat alphaOffset = 0.0;
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    if (isGreyscale)
        alphaOffset = oldComponents[1] > alpha ? oldComponents[1] - alpha : alpha - oldComponents[1];
    else
    {
        alphaOffset = oldComponents[3] > alpha ? oldComponents[3] - alpha : alpha - oldComponents[3];
        NSLog(@"dark alpha : %f, real : %f, offset : %f", alpha, oldComponents[3], alphaOffset);

    }
    
    return [UIColor darkerColorForColor:oldColor withRgbOffset:value andAlphaOffset:alphaOffset];
}


+ (UIColor *)darkerColorForColor:(UIColor *)oldColor withRgbOffset:(CGFloat)value andAlphaOffset:(CGFloat)alpha
{
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[1] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[2] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[3] = oldComponents[1]+alpha > 1.0 ? 1.0 : oldComponents[1]+alpha;
    } else {
        newComponents[0] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[1] = oldComponents[1]-value < 0.0 ? 0.0 : oldComponents[1]-value;
        newComponents[2] = oldComponents[2]-value < 0.0 ? 0.0 : oldComponents[2]-value;
        newComponents[3] = oldComponents[3]+alpha > 1.0 ? 1.0 : oldComponents[3]+alpha;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
    
}

@end
