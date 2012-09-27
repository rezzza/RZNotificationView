//
//  RZNotificationView.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "RZNotificationView.h"
#import <AudioToolbox/AudioServices.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MAX_MESSAGE_LENGHT 150
#define MIN_HEIGHT 40

@implementation RZNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* outerShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* innerShadowColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.5];
    
    UIColor* colorStart;
    UIColor* colorEnd;
    
    if( _customTopColor || _customBottomColor) {
        if( !_customTopColor)
            _customTopColor = _customBottomColor;
        
        if( !_customBottomColor)
            _customBottomColor = _customTopColor;
        
        colorStart = _customTopColor;
        colorEnd   = _customBottomColor;
    }
    else {
        switch (_color) {
            case RZNotificationColorGrey:
                colorStart = [UIColor colorWithRed: 162.0/255.0 green: 156.0/255.0 blue: 142.0/255.0 alpha: 1];
                colorEnd   = [UIColor colorWithRed: 123.0/255.0 green: 117.0/255.0 blue: 104.0/255.0 alpha: 1];
                break;
            case RZNotificationColorYellow:
                colorStart = [UIColor colorWithRed: 255.0/255.0 green: 204.0/255.0 blue: 0.0/255.0 alpha: 1];
                colorEnd   = [UIColor colorWithRed: 255.0/255.0 green: 174.0/255.0 blue: 0.0/255.0 alpha: 1];
                break;
            case RZNotificationColorRed:
                colorStart = [UIColor colorWithRed: 227.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 1];
                colorEnd   = [UIColor colorWithRed: 146.0/255.0 green: 20.0/255.0 blue: 20.0/255.0 alpha: 1];
                break;
            case RZNotificationColorBlue:
                colorStart = [UIColor colorWithRed: 110.0/255.0 green: 132.0/255.0 blue: 181.0/255.0 alpha: 1];
                colorEnd   = [UIColor colorWithRed: 59.0/255.0 green: 89.0/255.0 blue: 153.0/255.0 alpha: 1];
                break;
            default:
                colorStart = [UIColor colorWithRed: 162.0/255.0 green: 156.0/255.0 blue: 142.0/255.0 alpha: 1];
                colorEnd   = [UIColor colorWithRed: 123.0/255.0 green: 117.0/255.0 blue: 104.0/255.0 alpha: 1];
                break;
        }
    }
    
    //// Gradient Declarations
    NSArray* notificationBackgroundGradientColors = [NSArray arrayWithObjects:
                                                     (id)colorStart.CGColor,
                                                     (id)colorEnd.CGColor, nil];
    CGFloat notificationBackgroundGradientLocations[] = {0, 1};
    CGGradientRef notificationBackgroundGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)notificationBackgroundGradientColors, notificationBackgroundGradientLocations);
    
    //// Shadow Declarations
    UIColor* outerShadow = outerShadowColor;
    CGSize outerShadowOffset;
    CGFloat outerShadowBlurRadius = 3;
    UIColor* innerShadow = innerShadowColor;
    CGSize innerShadowOffset;;
    
    
    if (_position == RZNotificationPositionTop) {
        outerShadowOffset = CGSizeMake(0, 1);
        innerShadowOffset = CGSizeMake(0, -1);
    }
    else {
        outerShadowOffset = CGSizeMake(0, -1);
        innerShadowOffset = CGSizeMake(0, 1);
    }
    
    CGFloat innerShadowBlurRadius = 0;
    
    //// Frames
    CGRect notificationFrame = rect;
    
    //// Subframes
    _iconView.frame = CGRectMake(CGRectGetMinX(notificationFrame) + 8, CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 19) * 0.5), 19, 19);
    NSLog(@"** %@", NSStringFromCGRect(_textLabel.frame));
    _textLabel.frame = CGRectMake(CGRectGetMinX(notificationFrame) + 35, CGRectGetMinY(notificationFrame) + floor(CGRectGetHeight(notificationFrame) * 0.14), CGRectGetWidth(notificationFrame) - 70, floor(CGRectGetHeight(notificationFrame) * 0.72));
    NSLog(@"*** %@", NSStringFromCGRect(_textLabel.frame));

    CGRect _anchorFrame = CGRectMake(CGRectGetMinX(notificationFrame) + CGRectGetWidth(notificationFrame) - 27, CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 19) * 0.5), 19, 19);
    
    //// NotificationZone Drawing
    CGRect notificationZoneRect = CGRectMake(CGRectGetMinX(notificationFrame) + 0, CGRectGetMinY(notificationFrame) + (_position == RZNotificationPositionTop ? 0 : outerShadowBlurRadius), CGRectGetWidth(notificationFrame) - 0, CGRectGetHeight(notificationFrame) - (_position == RZNotificationPositionTop ?outerShadowBlurRadius : 0));
    CGRect notificationZoneRectExt = CGRectMake(CGRectGetMinX(notificationFrame) + 0, CGRectGetMinY(notificationFrame) + (_position == RZNotificationPositionTop ? 0 : -outerShadowBlurRadius), CGRectGetWidth(notificationFrame) - 0, CGRectGetHeight(notificationFrame) + (_position == RZNotificationPositionTop ? outerShadowBlurRadius : +outerShadowBlurRadius));

    UIBezierPath* notificationZonePath = [UIBezierPath bezierPathWithRect: notificationZoneRect];
    UIBezierPath* notificationZonePathExt = [UIBezierPath bezierPathWithRect: notificationZoneRectExt];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, outerShadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [notificationZonePathExt addClip];
    CGContextDrawLinearGradient(context, notificationBackgroundGradient,
                                CGPointMake(CGRectGetMidX(notificationZoneRect), CGRectGetMinY(notificationZoneRect)),
                                CGPointMake(CGRectGetMidX(notificationZoneRect), CGRectGetMaxY(notificationZoneRect)),
                                0);
    CGContextEndTransparencyLayer(context);
    
    ////// NotificationZone Inner Shadow
    CGRect notificationZoneBorderRect = CGRectInset([notificationZonePath bounds], -innerShadowBlurRadius, -innerShadowBlurRadius);
    notificationZoneBorderRect = CGRectOffset(notificationZoneBorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
    notificationZoneBorderRect = CGRectInset(CGRectUnion(notificationZoneBorderRect, [notificationZonePath bounds]), -1, -1);
    
    UIBezierPath* notificationZoneNegativePath = [UIBezierPath bezierPathWithRect: notificationZoneBorderRect];
    [notificationZoneNegativePath appendPath: notificationZonePath];
    notificationZoneNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = innerShadowOffset.width + round(notificationZoneBorderRect.size.width);
        CGFloat yOffset = innerShadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    innerShadowBlurRadius,
                                    innerShadow.CGColor);
        
        [notificationZonePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(notificationZoneBorderRect.size.width), 0);
        [notificationZoneNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [notificationZoneNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(notificationBackgroundGradient);
    CGColorSpaceRelease(colorSpace);
}

- (void) setIcon:(RZNotificationIcon)icon
{
    _icon = icon;
    switch (_icon) {
        case RZNotificationIconFacebook:
            _iconView.image = [UIImage imageNamed:@"notif_facebook.png"];
            break;
        case RZNotificationIconGift:
            _iconView.image = [UIImage imageNamed:@"notif_gift.png"];
            break;
        case RZNotificationIconInfo:
            _iconView.image = [UIImage imageNamed:@"notif_infos.png"];
            break;
        case RZNotificationIconSmiley:
            _iconView.image = [UIImage imageNamed:@"notif_smiley.png"];
            break;
        case RZNotificationIconTwitter:
            _iconView.image = [UIImage imageNamed:@"notif_twitter.png"];
            break;
        case RZNotificationIconWarning:
            _iconView.image = [UIImage imageNamed:@"notif_warning.png"];
            break;
        default:
            break;
    }
}

- (void) setColor:(RZNotificationColor)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void) setCustomTopColor:(UIColor *)customTopColor
{
    _customTopColor = customTopColor;
    [self setNeedsDisplay];
}

- (void) setCustomBottomColor:(UIColor *)customBottomColor
{
    _customBottomColor = customBottomColor;
    [self setNeedsDisplay];
}

- (void) setPosition:(RZNotificationPosition)position
{
    [self close];
    _position = position;
    [self setNeedsDisplay];
}

- (void) setMessage:(NSString *)message
{
    if(MAX_MESSAGE_LENGHT < [message length])
        message = [message substringToIndex:MAX_MESSAGE_LENGHT];
    _textLabel.text = message;
    
    CGRect frameL = self.frame;
    frameL.size.width = CGRectGetWidth(_textLabel.frame) - 70;
    _textLabel.frame = frameL;
    [_textLabel sizeToFit];
    
    CGRect frame = self.frame;
    if (MIN_HEIGHT < floor(CGRectGetHeight(_textLabel.frame) / 0.72)) {
        frame.size.height = floor(CGRectGetHeight(_textLabel.frame) / 0.72);
    }
    else{
        frame.size.height = MIN_HEIGHT;
    }
    self.frame = frame;
    
    [self setNeedsDisplay];
}

- (id) initWithMessage:(NSString*)message
{
    if ([message isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@", message] isEqualToString:@"(null)"])
    {
        return nil;
    }
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].applicationFrame), MIN_HEIGHT);
    
    self = [self initWithFrame:frame];
    
    if (self)
    {
        _message = message;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
       
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.contentMode = UIViewContentModeCenter | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_iconView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) - 70, 0)];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor colorWithWhite:0.0 alpha:1];
        _textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        _textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.textAlignment = UITextAlignmentLeft;
        _textLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:_textLabel];
        _textLabel.text = message;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}


- (void) showFromController:(UIViewController *)controller
{
    _controller = controller;
//    NSLog(@"%@", NSStringFromCGRect(controller.view.frame));
//    NSLog(@"%@", NSStringFromCGRect(controller.view.bounds));
    
    if (_position == RZNotificationPositionTop) {
        self.transform = CGAffineTransformMakeTranslation(0.0, -CGRectGetHeight(self.frame));
    }
    else{
        self.transform = CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(self.frame));
    }
    
//    if (controller.navigationController) {
//        CGRect frame = self.frame;
//        if (_position == RZNotificationPositionBottom) {
//            frame.origin.y = CGRectGetHeight(controller.view.frame);
//        }
//        else {
//            frame.origin.y = -CGRectGetHeight(self.frame);
//        }
//        self.frame = frame;
//        [controller.view insertSubview:self belowSubview:controller.navigationController.navigationBar];
//        NSLog(@"%@", NSStringFromCGRect(self.frame));
//    }
//    else
//    {
        CGRect frame = self.frame;
        if (_position == RZNotificationPositionBottom) {
            frame.origin.y = CGRectGetHeight(controller.view.frame);
        }
        else {
            frame.origin.y = -CGRectGetHeight(self.frame);
        }
        self.frame = frame;
        [controller.view addSubview:self];
//    }
    
    if(_vibrate)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [UIView animateWithDuration:0.4 animations:^{self.transform = CGAffineTransformIdentity;
    }];
    
    if(0.0 < _delay){
        [self performSelector:@selector(close)
               withObject:nil
               afterDelay:_delay];
    }
}

- (void) deviceOrientationChanged
{
    CGRect frame = self.frame;
    if (_position == RZNotificationPositionBottom) {
        frame.origin.y = CGRectGetHeight(_controller.view.frame) - self.frame.size.height;
    }
    else {
        frame.origin.y = 0.0;
    }
    if (_controller.view.frame.size.width != 0)
        frame.size.width = _controller.view.frame.size.width;
    self.frame = frame;
}

- (void) close
{
    
    _isTouch = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
    
    if (_position == RZNotificationPositionTop) {
        [UIView animateWithDuration:0.4 animations:^{
            self.transform = CGAffineTransformMakeTranslation(0.0, -CGRectGetHeight(self.frame));
        }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
    else {
        [UIView animateWithDuration:0.4 animations:^{
            self.transform = CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(self.frame));
        }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}


// Handles the start of a touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if(!_isTouch){
        _isTouch = YES;
        if(_delay == 0.0){
            if ([self.delegate respondsToSelector:@selector(notificationViewTouched:)]){
                [self.delegate notificationViewTouched:self];
                [self close];
            }
        }
        else{
            if ([self.delegate respondsToSelector:@selector(notificationViewTouched:)]){
                [self.delegate notificationViewTouched:self];
            }
            [self close];
        }
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
