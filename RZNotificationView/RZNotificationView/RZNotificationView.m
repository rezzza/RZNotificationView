//
//  RZNotificationView.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "RZNotificationView.h"
#import "UIView+Frame.h"

#import "MOOMaskedIconView.h"
#import "MOOStyleTrait.h"

#import <AudioToolbox/AudioServices.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MAX_MESSAGE_LENGHT 150
#define MIN_HEIGHT 40

#define OFFSET_X 35.0

#define DEFAULT_POSITION RZNotificationPositionTop
#define DEFAULT_DELAY 3.5
#define DEFAULT_COLOR RZNotificationColorBlue
#define DEFAULT_VIBRATE NO
#define DEFAULT_ASSET_COLOR RZNotificationAssetColorAutomaticLight
#define DEFAULT_ICON RZNotificationIconFacebook

@interface RZNotificationView ()
@property (nonatomic, strong) UIViewController *controller;
@end

@implementation RZNotificationView

#pragma mark - Color Adjustements

- (UIColor*) adjustAssetsColor:(UIColor*)c
{
    if(_assetColor == RZNotificationAssetColorAutomaticDark)
        return [self darkerColorForColor:c];
    
    if(_assetColor == RZNotificationAssetColorAutomaticLight)
        return [self lighterColorForColor:c];
    
    return c;
}

- (UIColor *)lighterColorForColor:(UIColor *)c withOffset:(CGFloat)o
{
    float r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + o, 1.0)
                               green:MIN(g + o, 1.0)
                                blue:MIN(b + o, 1.0)
                               alpha:a];
    return nil;
}
- (UIColor *)lighterColorForColor:(UIColor *)c
{
    return [self lighterColorForColor:c withOffset:0.3f];
}

- (UIColor *)darkerColorForColor:(UIColor *)c withOffset:(CGFloat)o
{
    float r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - o, 0.0)
                               green:MAX(g - o, 0.0)
                                blue:MAX(b - o, 0.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    return [self darkerColorForColor:c withOffset:0.3f];
}

#pragma mark - Drawings

- (UIImage *)image:(UIImage *)img withColor:(UIColor *)color
{
    MOOStyleTrait *iconTrait = [MOOStyleTrait trait];
    
    if (_assetColor == RZNotificationAssetColorAutomaticLight)
    {
        iconTrait.gradientColors = [NSArray arrayWithObjects:
                                    [self lighterColorForColor:color withOffset:0.2],
                                    [self lighterColorForColor:color withOffset:0.1], nil];
        iconTrait.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        iconTrait.innerShadowColor = [self darkerColorForColor:color];
        iconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
        iconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);
    }
    else if (_assetColor == RZNotificationAssetColorAutomaticDark)
    {
        iconTrait.gradientColors = [NSArray arrayWithObjects:
                                    [self darkerColorForColor:color withOffset:0.2],
                                    [self darkerColorForColor:color withOffset:0.1], nil];
        iconTrait.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        iconTrait.innerShadowColor = [self lighterColorForColor:color];
        iconTrait.shadowOffset = CGSizeMake(0.0f, 1.0f);
        iconTrait.innerShadowOffset = CGSizeMake(0.0f, 1.0f);
    }
    
    MOOMaskedIconView *iconView = [MOOMaskedIconView iconWithImage:img];
    [iconView mixInTrait:iconTrait];
    
    return [iconView renderImage];
}

- (void) drawRect:(CGRect)rect
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
    CGRect contentFrame = CGRectMake(CGRectGetMinX(notificationFrame) + OFFSET_X, CGRectGetMinY(notificationFrame) + floor(CGRectGetHeight(notificationFrame) * 0.14), CGRectGetWidth(notificationFrame) - 2*OFFSET_X, floor(CGRectGetHeight(notificationFrame) * 0.72));
    _textLabel.frame = contentFrame;
    [_customView setFrame:contentFrame];
    _anchorView.frame = CGRectMake(CGRectGetMinX(notificationFrame) + CGRectGetWidth(notificationFrame) - 27, CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 19) * 0.5), 19, 19);
    
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
    
    _iconView.image = [self image:[self getImageForIcon:_icon] withColor:colorStart];
    _anchorView.image = [self image:[UIImage imageNamed:@"ico-anchor-white.png"] withColor:colorStart];
    if (_assetColor != RZNotificationAssetColorManual) {
        _textLabel.textColor = [self adjustAssetsColor:colorStart];
        if(_assetColor == RZNotificationAssetColorAutomaticDark)
            _textLabel.shadowColor = [UIColor whiteColor];
        if(_assetColor == RZNotificationAssetColorAutomaticLight)
            _textLabel.shadowColor = [UIColor blackColor];
    }
}

#pragma mark - Getters and Setters

- (UIImage *) getImageForIcon:(RZNotificationIcon)icon
{
    UIImage *image = nil;
    switch (_icon) {
        case RZNotificationIconFacebook:
            image = [UIImage imageNamed:@"notif_facebook.png"];
            break;
        case RZNotificationIconGift:
            image = [UIImage imageNamed:@"notif_gift.png"];
            break;
        case RZNotificationIconInfo:
            image = [UIImage imageNamed:@"notif_infos.png"];
            break;
        case RZNotificationIconSmiley:
            image = [UIImage imageNamed:@"notif_smiley.png"];
            break;
        case RZNotificationIconTwitter:
            image = [UIImage imageNamed:@"notif_twitter.png"];
            break;
        case RZNotificationIconWarning:
            image = [UIImage imageNamed:@"notif_warning.png"];
            break;
        default:
            break;
    }
    return image;
}

- (void) setColor:(RZNotificationColor)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void) setAssetColor:(RZNotificationAssetColor)assetColor
{
    _assetColor = assetColor;
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
    _position = position;
    [self setNeedsDisplay];
}

- (void) setMessage:(NSString *)message
{
    _message = message;
    if(MAX_MESSAGE_LENGHT < [message length])
        message = [message substringToIndex:MAX_MESSAGE_LENGHT];
    
    if ([(UIView*)_customView superview]) {
        [_customView removeFromSuperview];
    }
    
    [self addTextLabelIfNeeded];
    
    _textLabel.text = message;
    
    CGRect frameL = self.frame;
    frameL.size.width -= 2*OFFSET_X;
    _textLabel.frame = frameL;
    [_textLabel sizeToFit];
    
    [self adjustHeighAndRedraw:CGRectGetHeight(_textLabel.frame)];
}

- (void) setSound:(NSString *)sound
{
    _sound = sound;
    //NSString *test = [sound ]
    NSURL *soundURL   = [[NSBundle mainBundle] URLForResource: [_sound stringByDeletingPathExtension]
                                                withExtension: [_sound pathExtension]];
    
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
                                      (__bridge CFURLRef)(soundURL),
                                      &soundFileObject
                                      );
}

- (void) adjustHeighAndRedraw:(CGFloat)height
{
    CGRect frame = self.frame;
    if (MIN_HEIGHT < floor(height / 0.72)) { //calculation given by paintcode
        frame.size.height = floor(height / 0.72);
    }
    else{
        frame.size.height = MIN_HEIGHT;
    }
    self.frame = frame;
    [self setNeedsDisplay];
}

- (void) setCustomView:(id<RZNotificationLabelProtocol>)customView
{
    if(customView){
        [_textLabel removeFromSuperview];
        [_customView removeFromSuperview];
        _customView = customView;
        _textLabel = nil;
        [self addSubview:(UIView*)_customView];
    }
    else{
        [_customView removeFromSuperview];
        
        [self addTextLabelIfNeeded];
        
        _textLabel.text = _message;
    }
}

- (void) setActionToCall:(SEL)actionToCall withParam:(id)param
{
    _actionToCall = actionToCall;
    _actionParam = param;
}

#pragma mark - Subviews build

- (void) addTextLabelIfNeeded
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - 2*OFFSET_X, 0)];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (RZSystemVersionGreaterOrEqualThan(6.0))
        {
            _textLabel.textAlignment = NSTextAlignmentLeft;
            _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        else
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _textLabel.textAlignment = UITextAlignmentLeft;
            _textLabel.lineBreakMode = UILineBreakModeWordWrap;
#pragma clang diagnostic pop
        }
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.shadowColor = [UIColor whiteColor];
    }
    
    if (!_textLabel.superview)
        [self addSubview:_textLabel];
}

#pragma mark - Init methods

- (id) initWithFrame:(CGRect)frame icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor delay:(NSTimeInterval)delay
{
    CGRect mFrame = frame;
    mFrame.size.height = MAX(CGRectGetHeight(frame), MIN_HEIGHT);
    
    self = [super initWithFrame:mFrame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Set default values
        _delay = delay;
        _position = position;
        _color = color;
        _vibrate = DEFAULT_VIBRATE;
        _assetColor = assetColor;
        _icon = icon;
        
        // Add icon view
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
        
        // Add Anchor view
        _anchorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico-anchor-white.png"]];
        _anchorView.contentMode = UIViewContentModeCenter;
        _anchorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_anchorView];
        
        // Initialize the text label
        [self addTextLabelIfNeeded];
        
        // Observe device orientation changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
 
}

- (id) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
                          icon:DEFAULT_ICON
                      position:DEFAULT_POSITION
                         color:DEFAULT_COLOR
                    assetColor:DEFAULT_ASSET_COLOR
                         delay:DEFAULT_DELAY];
}

- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor delay:(NSTimeInterval)delay
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetWidth(controller.view.frame);
    self = [self initWithFrame:frame
                          icon:icon
                      position:position
                         color:color
                    assetColor:assetColor
                         delay:delay];
    if (self)
    {
        self.controller = controller;
    }
    return self;
}

- (id) initWithController:(UIViewController*)controller
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetWidth(controller.view.frame);
    self = [self initWithFrame:frame];
    if (self)
    {
        self.controller = controller;
    }
    return self;
}

// Freely adapted from MBProgressHUD
+ (RZNotificationView *)showNotificationWithMessage:(NSString *)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor addedToController:(UIViewController *)controller
{
    return [RZNotificationView showNotificationWithMessage:message
                                                      icon:icon
                                                  position:position
                                                     color:color
                                                assetColor:assetColor
                                                     delay:DEFAULT_DELAY
                                         addedToController:controller];
}

+ (RZNotificationView *)showNotificationWithMessage:(NSString *)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor delay:(NSTimeInterval)delay addedToController:(UIViewController *)controller
{
    RZNotificationView *notification = [[RZNotificationView alloc] initWithController:controller
                                                                                 icon:icon
                                                                             position:position
                                                                                color:color
                                                                           assetColor:assetColor
                                                                                delay:delay];
    [notification setMessage:message];
    [notification show];
    return notification;
}

+ (BOOL) hideNotificationForController:(UIViewController*)controller
{
    RZNotificationView *notification = [RZNotificationView notificationForController:controller];
	if (notification != nil) {
		[notification hide];
		return YES;
	}
	return NO;
}

+ (NSUInteger)hideAllNotificationsForController:(UIViewController *)controller
{
    NSArray *notififications = [self allNotificationsForController:controller];
	for (RZNotificationView *notification in notififications) {
		[notification hide];
	}
	return [notififications count];
}

+ (RZNotificationView*) notificationForController:(UIViewController*)controller
{
    RZNotificationView *notification = nil;
	NSArray *subviews = controller.view.subviews;
	Class notificationClass = [RZNotificationView class];
	for (UIView *aView in subviews) {
		if ([aView isKindOfClass:notificationClass]) {
			notification = (RZNotificationView *)aView;
		}
	}
	return notification;
}

+ (NSArray*) allNotificationsForController:(UIViewController*)controller
{
    NSMutableArray *notifications = [NSMutableArray array];
	NSArray *subviews = controller.view.subviews;
	Class notificationClass = [RZNotificationView class];
	for (UIView *aView in subviews) {
		if ([aView isKindOfClass:notificationClass]) {
			[notifications addObject:aView];
		}
	}
	return [NSArray arrayWithArray:notifications];
}

- (void) placeToOrigin
{
    if (_position == RZNotificationPositionTop) {
        [self setYOrigin:-CGRectGetHeight(self.frame)];
    }
    else {
        [self setYOrigin:CGRectGetHeight(_controller.view.frame)];
    }
}

- (void) placeToFinalPosition
{
    if (_position == RZNotificationPositionTop) {
        [self setYOrigin:0.0];
    }
    else{
        [self setYOrigin:CGRectGetHeight(_controller.view.frame)-CGRectGetHeight(self.frame)];
    }
}

- (void) show
{
    [self placeToOrigin];
    
    if (_position == RZNotificationPositionTop) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    else{
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    [_controller.view addSubview:self];
    
    if(_vibrate)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if(_sound)
        AudioServicesPlaySystemSound (soundFileObject);
    
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self placeToFinalPosition];
                     }
     ];
    
    [self hideAfterDelay:_delay];
}

- (void) hide
{
    _isTouch = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self placeToOrigin];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void) hideAfterDelay:(NSTimeInterval)delay
{
    if(0.0 < delay)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
        [self performSelector:@selector(hide) withObject:nil afterDelay:delay];
    }
}

- (void) deviceOrientationDidChange:(NSNotification*)notification
{
    if(self.superview){
        if(_textLabel){
            self.message = _message;
        }
        else{
            CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame)-2*OFFSET_X];
            [self adjustHeighAndRedraw:height];
        }
        
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
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_isTouch){
        _isTouch = YES;
        if(_delay == 0.0){
            if ([self.delegate respondsToSelector:@selector(notificationViewTouched:)]){
                [self.delegate notificationViewTouched:self];
                [self hide];
            }
        }
        else{
            if ([self.delegate respondsToSelector:@selector(notificationViewTouched:)]){
                [self.delegate notificationViewTouched:self];
            }
            [self hide];
        }
    }
    if([_controller respondsToSelector:_actionToCall]){
        if(!_actionParam)
            _actionParam = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_controller performSelector:_actionToCall withObject:_actionParam];
#pragma clang diagnostic pop
        
    }
    if (_urlToOpen) {
        if ([[UIApplication sharedApplication] canOpenURL:_urlToOpen]) {
            [[UIApplication sharedApplication] openURL:_urlToOpen];
        }
    }
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
