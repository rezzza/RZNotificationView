//
//  RZNotificationView.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "RZNotificationView.h"

#define WIDTH_SUPERVIEW 320
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation RZNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *topColor = [UIColor colorWithRed:162.0/255.0 green:156.0/255.0 blue:142.0/255.0 alpha:1.0];
    UIColor *bottomColor = [UIColor colorWithRed:123.0/255.0 green:117.0/255.0 blue:104.0/255.0 alpha:1.0];
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
	
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor, nil];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
	
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
    
    if (_position == RZNotificationPositionTop) {
        CGContextSaveGState(context);
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, 0.0, rect.size.height - 1.0);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1.0);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    else {
        CGContextSaveGState(context);
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, 0.0, 0.0);
        CGContextAddLineToPoint(context, rect.size.width, 0.0);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
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
            _iconView.image = [UIImage imageNamed:@"notif_info.png"];
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

- (id) initWithMessage:(NSString*)message
{
    _message = message;
    if ([message isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@", message] isEqualToString:@"(null)"])
    {
        return nil;
    }
    
    CGRect frame;
    frame.origin.x = 0.0;
    frame.size = CGSizeMake(WIDTH_SUPERVIEW, 90);
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
       
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _iconView.contentMode = UIViewContentModeCenter;
        CGRect newFrame = _iconView.frame;
        newFrame.origin.y = self.center.y - newFrame.size.height/2.0;
        newFrame.origin.x = 15.0;
        _iconView.frame = newFrame;
        [self addSubview:_iconView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, WIDTH_SUPERVIEW-20.0, 80.0)];
        label.numberOfLines = 4;
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:label];
        label.text = message;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}


- (void) showFromController:(UIViewController *)controller
{

//    NSLog(@"%@", NSStringFromCGRect(controller.view.frame));
//    NSLog(@"%@", NSStringFromCGRect(controller.view.bounds));
    
    if (_position == RZNotificationPositionTop) {
        self.transform = CGAffineTransformMakeTranslation(0.0, -CGRectGetHeight(self.frame));
    }
    else{
        self.transform = CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(self.frame));
    }
    
    if (controller.navigationController) {
        if (_position == RZNotificationPositionBottom) {
            CGRect frame = self.frame;
            frame.origin.y = CGRectGetHeight(controller.view.frame);
            self.frame = frame;
        }
        [controller.view insertSubview:self belowSubview:controller.navigationController.navigationBar];
    }
    else
    {

        if (_position == RZNotificationPositionBottom) {
            CGRect frame = self.frame;
            frame.origin.y = CGRectGetHeight(controller.view.frame);
            self.frame = frame;
        }
        [controller.view addSubview:self];
    }
    
    [UIView animateWithDuration:0.4 animations:^{self.transform = CGAffineTransformIdentity;
    }];
    
    if(0.0 < _delay){
        [self performSelector:@selector(close)
               withObject:nil
               afterDelay:_delay];
    }
}

- (void) close
{
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


@end
