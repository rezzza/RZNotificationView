//
//  RZNotificationView.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "RZNotificationView.h"
#import "UIView+Frame.h"

#import "UIColor+RZAdditions.h"

#import <MOOMaskedIconView/MOOMaskedIconView.h>
#import <MOOMaskedIconView/MOOStyleTrait.h>

#import <AudioToolbox/AudioServices.h>

#define RZUIColorFromRGB(rgbValue) [UIColor               \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0           \
blue:((float)(rgbValue & 0xFF))/255.0                     \
alpha:1.0]

static const NSInteger kDefaultMaxMessageLength            = 150;
static const CGFloat kDefaultContentMarginHeight           = 16.0f;
static const RZNotificationPosition kDefaultPosition       = RZNotificationPositionTop;
static const RZNotificationColor kDefaultColor             = RZNotificationColorBlue;
static const BOOL kDefaultVibrate                          = NO;
static const RZNotificationContentColor kDefaultAssetColor = RZNotificationContentColorAutomaticDark;
static const RZNotificationContentColor kDefaultTextColor  = RZNotificationContentColorAutomaticLight;
static const RZNotificationIcon kDefaultIcon               = RZNotificationIconFacebook;
static const NSTimeInterval kDefaultDelay                  = 3.5;

static const CGFloat kMinHeight                            = 64.0f;
static const CGFloat kOffsetX                              = 35.0f;

static BOOL RZOrientationMaskContainsOrientation(UIInterfaceOrientationMask mask, UIInterfaceOrientation orientation);

@interface RZNotificationView ()
{
    BOOL _isShowing;
    BOOL _hasPlayedSound;
    BOOL _hasVibrate;
    
    UIView *_highlightedView;
}
@property (nonatomic, strong) UIViewController *controller;
@end

@implementation RZNotificationView

#pragma mark - Get Offset

- (CGFloat) getOffsetXLeft
{
    CGFloat icontWitdhFree = 0.0;
    if (![self getImageForIcon:_icon]) {
        icontWitdhFree = 21.0;
    }
    
    return kOffsetX - icontWitdhFree;
}

- (CGFloat) getOffsetXRight
{
    CGFloat anchorWitdhFree = 21.0;
    if (_displayAnchor) {
        anchorWitdhFree = 0.0;
    }
    
    return kOffsetX - anchorWitdhFree;
}

#pragma mark - Color Adjustements

- (UIColor*) adjustTextColor:(UIColor*)c
{
    if(_textColor == RZNotificationContentColorAutomaticDark)
        return [UIColor darkerColorForColor:c withRgbOffset:0.55];
    
    if(_textColor == RZNotificationContentColorAutomaticLight)
        return [UIColor lighterColorForColor:c withRgbOffset:0.9];
    
    return c;
}

#pragma mark - Drawings

- (UIImage *)image:(UIImage *)img withColor:(UIColor *)color
{
    MOOStyleTrait *iconTrait = [MOOStyleTrait trait];
    
    switch(_assetColor)
    {
        case RZNotificationContentColorAutomaticLight:
            iconTrait.color = [UIColor whiteColor];
            break;
        case RZNotificationContentColorAutomaticDark:
            iconTrait.color = [UIColor colorWithWhite:76.0f/255.0f alpha:1.0f];
            break;
        case RZNotificationContentColorManual:
            NSLog(@"Warning, setting RZNotificationContentColorManual for assetColor is not supported. Setting to textColor");
            if (_textColor != RZNotificationContentColorManual)
                _assetColor = _textColor;
            else
                _assetColor = RZNotificationContentColorAutomaticLight;
            
            return [self image:img withColor:color];
            break;
    }
    
    MOOMaskedIconView *iconView = [MOOMaskedIconView iconWithImage:img];
    [iconView mixInTrait:iconTrait];
    
    return [iconView renderImage];
}

- (void) drawRect:(CGRect)rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    
    UIColor* colorStart = nil;
    UIColor* colorEnd = nil;
    
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
                break;
            case RZNotificationColorYellow:
                colorStart = [UIColor colorWithRed: 255.0/255.0 green: 204.0/255.0 blue: 0.0/255.0 alpha: 1];
                break;
            case RZNotificationColorRed:
                colorStart = [UIColor colorWithRed: 227.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 1];
                break;
            case RZNotificationColorBlue:
                colorStart = [UIColor colorWithRed: 110.0/255.0 green: 132.0/255.0 blue: 181.0/255.0 alpha: 1];
                break;
            default:
                colorStart = [UIColor colorWithRed: 162.0/255.0 green: 156.0/255.0 blue: 142.0/255.0 alpha: 1];
                break;
        }
    }
    
    
    //// Frames
    CGRect notificationFrame = rect;
    
    CGContextSaveGState(context);

    if (colorEnd) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        //// Gradient Declarations
        NSArray* notificationBackgroundGradientColors = [NSArray arrayWithObjects:
                                                         (id)colorStart.CGColor,
                                                         (id)colorEnd.CGColor, nil];
        CGFloat notificationBackgroundGradientLocations[] = {0, 1};
        CGGradientRef notificationBackgroundGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)notificationBackgroundGradientColors, notificationBackgroundGradientLocations);
        
        //// NotificationZone Drawing
        CGRect notificationZoneRect = notificationFrame;
        CGRect notificationZoneRectExt = notificationFrame;
        
        UIBezierPath* notificationZonePathExt = [UIBezierPath bezierPathWithRect: notificationZoneRectExt];
        
        CGContextBeginTransparencyLayer(context, NULL);
        [notificationZonePathExt addClip];
        CGContextDrawLinearGradient(context, notificationBackgroundGradient,
                                    CGPointMake(CGRectGetMidX(notificationZoneRect), CGRectGetMinY(notificationZoneRect)),
                                    CGPointMake(CGRectGetMidX(notificationZoneRect), CGRectGetMaxY(notificationZoneRect)),
                                    0);
        CGContextEndTransparencyLayer(context);
        
        //// Cleanup
        CGGradientRelease(notificationBackgroundGradient);
        CGColorSpaceRelease(colorSpace);
    }
    else {
        CGContextSetFillColorWithColor(context, colorStart.CGColor);
        CGContextFillRect(context, notificationFrame);
        
        // Draw stroke
        UIColor *strokeColor = [UIColor lighterColorForColor:colorStart withRgbOffset:0.1f];
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextStrokeRect(context, notificationFrame);
    }
    
    CGContextRestoreGState(context);
    
    //// Subframes
    _iconView.frame = CGRectMake(CGRectGetMinX(notificationFrame) + 7,
                                 CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 22) * 0.5),
                                 21,
                                 22);
    
    CGRect contentFrame = CGRectMake(CGRectGetMinX(notificationFrame) + [self getOffsetXLeft],
                                     CGRectGetMinY(notificationFrame) + CGRectGetMinY(notificationFrame) + _contentMarginHeight,
                                     CGRectGetWidth(notificationFrame) - [self getOffsetXLeft] - [self getOffsetXRight],
                                     CGRectGetHeight(notificationFrame) - 2*_contentMarginHeight);
    _textLabel.frame = contentFrame;
    [_customView setFrame:contentFrame];
    _anchorView.frame = CGRectMake(CGRectGetMinX(notificationFrame) + CGRectGetWidth(notificationFrame) - 26, CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 22) * 0.5), 21, 22);
    
    _iconView.image = [self image:[self getImageForIcon:_icon] withColor:colorStart];
    _anchorView.image = [self image:[UIImage imageNamed:@"notif_anchor"] withColor:colorStart];
    
    if (_textColor != RZNotificationContentColorManual) {
        _textLabel.textColor = [self adjustTextColor:colorStart];
    }
}

#pragma mark - Getters and Setters

- (UIImage *) getImageForIcon:(RZNotificationIcon)icon
{
    NSString *imageName = nil;
    switch (_icon) {
        case RZNotificationIconFacebook:
            imageName = @"notif_facebook";
            break;
        case RZNotificationIconGift:
            imageName = @"notif_gift";
            break;
        case RZNotificationIconInfo:
            imageName = @"notif_infos";
            break;
        case RZNotificationIconSmiley:
            imageName = @"notif_smiley";
            break;
        case RZNotificationIconTwitter:
            imageName = @"notif_twitter";
            break;
        case RZNotificationIconWarning:
            imageName = @"notif_warning";
            break;
        case RZNotificationIconCustom:
            imageName = _customIcon;
            break;
        case RZNotificationIconNone:
            imageName = nil;
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (void) setCustomIcon:(NSString *)customIcon
{
    _customIcon = customIcon;
    if (customIcon) {
        _icon = RZNotificationIconCustom;
    }
    else {
        _icon = RZNotificationIconNone;
    }
}

- (void) setColor:(RZNotificationColor)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void) setAssetColor:(RZNotificationContentColor)assetColor
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
    NSString *tempMessage = message;
    _message = message;
    
    NSInteger maxLenght = _messageMaxLenght;
    if (maxLenght == 0)
        maxLenght = kDefaultMaxMessageLength;
    
    if(maxLenght < [message length])
        tempMessage = [[message substringToIndex:maxLenght] stringByAppendingString:@"..."]; // Tail truncation
    
    if ([(UIView*)_customView superview]) {
        [_customView removeFromSuperview];
    }
    
    [self addTextLabelIfNeeded];
    
    _textLabel.text = tempMessage;
    
    CGRect frameL = self.frame;
    frameL.size.width -= [self getOffsetXLeft] + [self getOffsetXRight];
    _textLabel.frame   = frameL;
    [_textLabel sizeToFit];
    
    _textLabel.text = message;
    
    [self adjustHeightAndRedraw:CGRectGetHeight(_textLabel.frame)];
}

- (void) setSound:(NSString *)sound
{
    if(sound && ((NSNull*)sound != [NSNull null])) {
        _sound = sound;
        
        NSURL *soundURL   = [[NSBundle mainBundle] URLForResource: [_sound stringByDeletingPathExtension]
                                                    withExtension: [_sound pathExtension]];
        
        // Create a system sound object representing the sound file.
        AudioServicesCreateSystemSoundID (
                                          (__bridge CFURLRef)(soundURL),
                                          &_soundFileObject
                                          );
        
        if (_isShowing && !_hasPlayedSound && sound) {
            // Then we play the sound for the first time
            // This happens when you use [RZNotificationView showNotification ...]
            AudioServicesPlaySystemSound (_soundFileObject);
            _hasPlayedSound = YES;
        }
    }
}

- (void) setVibrate:(BOOL)vibrate
{
    _vibrate = vibrate;
    
    if (_isShowing && !_hasVibrate && vibrate) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        _hasVibrate = YES;
    }
}

- (void) setContentMarginHeight:(CGFloat)contentMarginHeight
{
    _contentMarginHeight = contentMarginHeight;
    
    CGFloat height;
    
    if ([(UIView*)_customView superview]) {
        height = [_customView resizeForWidth:CGRectGetWidth(self.frame) - [self getOffsetXLeft] - [self getOffsetXRight]];
    }
    else{
        height = CGRectGetHeight(_textLabel.frame);
    }
    [self adjustHeightAndRedraw:height];
}

- (void) setDisplayAnchor:(BOOL)displayAnchor
{
    _displayAnchor = displayAnchor;
    if (_displayAnchor && !_anchorView.superview) {
        [self addSubview:_anchorView];
    }
    else if (!_displayAnchor && _anchorView.superview){
        [_anchorView removeFromSuperview];
    }
}

- (void) setCustomView:(id<RZNotificationLabelProtocol>)customView
{
    if(customView){
        [_textLabel removeFromSuperview];
        [_customView removeFromSuperview];
        _customView = customView;
        [self addSubview:(UIView*)_customView];
    }
    else{
        [_customView removeFromSuperview];
        
        [self addTextLabelIfNeeded];
        
        _textLabel.text = _message;
    }
}

- (void) setCompletionBlock:(RZNotificationCompletion)completionBlock
{
    if (completionBlock == nil) {
        [_anchorView removeFromSuperview];
    }
    else
    {
        if (!_anchorView.superview) {
            [self insertSubview:_anchorView aboveSubview:_textLabel];
        }
    }
    
    _completionBlock = completionBlock;
}

- (void) setMessageMaxLenght:(NSInteger)messageMaxLenght
{
    _messageMaxLenght = messageMaxLenght;
    if (_message && _textLabel.superview) {
        [self setMessage:_message];
    }
}

#pragma mark - Subviews build

- (void) addTextLabelIfNeeded
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - [self getOffsetXLeft] - [self getOffsetXRight], 0)];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (RZSystemVersionGreaterOrEqualThan(6.0))
        {
            _textLabel.textAlignment = NSTextAlignmentLeft;
            _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        else
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _textLabel.textAlignment = UITextAlignmentLeft;
            _textLabel.lineBreakMode = UILineBreakModeTailTruncation;
#pragma clang diagnostic pop
        }
        _textLabel.textColor = [UIColor blackColor];
    }
    
    if (!_textLabel.superview)
        [self addSubview:_textLabel];
}

#pragma mark - Init methods

- (id) initWithFrame:(CGRect)frame icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay
{
    CGRect mFrame = frame;
    mFrame.size.height = MAX(CGRectGetHeight(frame), kMinHeight);
    
    self = [super initWithFrame:mFrame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Set default values
        _delay = delay;
        _position = position;
        _color = color;
        _vibrate = kDefaultVibrate;
        _assetColor = assetColor;
        _textColor = textColor;
        _icon = icon;
        _displayAnchor = YES;
        _contentMarginHeight = kDefaultContentMarginHeight;
        
        // Add icon view
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.clipsToBounds = NO;
        _iconView.opaque = YES;
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
        
        // Add Anchor view
        _anchorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notif_anchor"]];
        _anchorView.contentMode = UIViewContentModeCenter;
        _anchorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _anchorView.clipsToBounds = NO;
        _anchorView.opaque = YES;
        _anchorView.backgroundColor = [UIColor clearColor];
        [self addSubview:_anchorView];
        
        // Initialize the text label
        [self addTextLabelIfNeeded];
        
        // Observe device orientation changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        // Handle touch
        [self addTarget:self
                 action:@selector(handleTouch)
       forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
    
}

- (id) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
                          icon:kDefaultIcon
                      position:kDefaultPosition
                         color:kDefaultColor
                    assetColor:kDefaultAssetColor
                     textColor:kDefaultTextColor
                         delay:kDefaultDelay];
}

- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor delay:(NSTimeInterval)delay
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetWidth(controller.view.frame);
    self = [self initWithFrame:frame
                          icon:icon
                      position:position
                         color:color
                    assetColor:assetColor
                     textColor:assetColor
                         delay:delay];
    if (self)
    {
        self.controller = controller;
    }
    return self;
}

- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay completion:(RZNotificationCompletion)completionBlock;
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetWidth(controller.view.frame);
    
    self = [self initWithFrame:frame
                          icon:icon
                      position:position
                         color:color
                    assetColor:assetColor
                     textColor:textColor
                         delay:delay];
    if (self)
    {
        self.controller = controller;
        self.completionBlock = completionBlock;
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
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor  textColor:(RZNotificationContentColor)textColor addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock
{
    return [RZNotificationView showNotificationWithMessage:message
                                                      icon:icon
                                                  position:position
                                                     color:color
                                                assetColor:assetColor
                                                 textColor:textColor
                                                     delay:kDefaultDelay
                                         addedToController:controller
                                            withCompletion:completionBlock];
}

+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor  delay:(NSTimeInterval)delay addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock;
{
    RZNotificationView *notification = [[RZNotificationView alloc] initWithController:controller
                                                                                 icon:icon
                                                                             position:position
                                                                                color:color
                                                                           assetColor:assetColor
                                                                            textColor:textColor
                                                                                delay:delay
                                                                           completion:completionBlock];
    [notification setMessage:message];
    [notification show];
    return notification;
}

+ (RZNotificationView *)showNotificationOnTopMostControllerWithMessage:(NSString *)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor withCompletion:(RZNotificationCompletion)completionBlock
{
    
    return [RZNotificationView showNotificationOnTopMostControllerWithMessage:message
                                                                         icon:icon
                                                                     position:position
                                                                        color:color
                                                                   assetColor:assetColor
                                                                    textColor:textColor
                                                                        delay:kDefaultDelay
                                                               withCompletion:completionBlock];
}

+ (RZNotificationView *)showNotificationOnTopMostControllerWithMessage:(NSString *)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay withCompletion:(RZNotificationCompletion)completionBlock
{
    RZNotificationView *notification = [[RZNotificationView alloc] initWithController:[UIViewController topMostController]
                                                                                 icon:icon
                                                                             position:position
                                                                                color:color
                                                                           assetColor:assetColor
                                                                            textColor:textColor
                                                                                delay:delay
                                                                           completion:completionBlock];
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

#pragma mark - Show hide methods
- (CGFloat) _getFinalOriginForPosition:(RZNotificationPosition)position
{
    UIViewController *c = _controller;
    CGFloat finalOrigin = 0.0f;
    
    if ([c conformsToProtocol:@protocol(RZNotificationViewProtocol)]) {
        finalOrigin = [(UIViewController<RZNotificationViewProtocol>*)c yOriginForRZNotificationViewForPosition:position];
    } else {
        if (position == RZNotificationPositionTop) {
            finalOrigin = [c.topLayoutGuide length];
        } else {
            finalOrigin = CGRectGetHeight(_controller.view.frame) - [c.bottomLayoutGuide length];
        }
    }
    
    return finalOrigin;
}

- (void) placeToOrigin
{
    CGFloat yOrigin = 0.0f;
    
    if (_position == RZNotificationPositionTop) {
        yOrigin = -CGRectGetHeight(self.frame);
    }
    else {
        yOrigin = CGRectGetHeight(_controller.view.frame);
    }
    
    [self setYOrigin:yOrigin];
}

- (void) placeToFinalPosition
{
    CGFloat yFinalOrigin = 0.0f;
    
    if (_position == RZNotificationPositionTop) {
        yFinalOrigin = [self _getFinalOriginForPosition:_position];
    } else {
        yFinalOrigin = [self _getFinalOriginForPosition:_position]-CGRectGetHeight(self.frame);
    }
    
    [self setYOrigin:yFinalOrigin];
}

- (void) show
{
    if (_customView) {
        CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame) - [self getOffsetXLeft] - [self getOffsetXRight]];
        [self adjustHeightAndRedraw:height];
    }
    
    self.hidden = YES;
    [self placeToOrigin];
    
    _isShowing = YES;
    
    if (_position == RZNotificationPositionTop) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    else{
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    if ([_controller conformsToProtocol:@protocol(RZNotificationViewProtocol)]) {
        [(UIViewController<RZNotificationViewProtocol>*)_controller addRZNotificationView:self];
    } else {
        [_controller.view addSubview:self];
    }
    
    if(_vibrate)
    {
        _hasVibrate = YES;
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if(_sound)
    {
        _hasPlayedSound = YES;
        AudioServicesPlaySystemSound (_soundFileObject);
    }
    
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.hidden = NO;
                         [self placeToFinalPosition];
                     }
     ];
    
    [self hideAfterDelay:_delay];
}

- (void) hide
{
    if (_completionBlock)
        _completionBlock(_isTouch);
    
    _isTouch = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self placeToOrigin];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         _isShowing = NO;
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

- (void) adjustHeightAndRedraw:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = MAX(kMinHeight , height + 2.0*_contentMarginHeight);
    self.frame = frame;
    [self setNeedsDisplay];
}

#pragma mark - Rotation handling

- (void) deviceOrientationDidChange:(NSNotification*)notification
{
    if(self.superview){
        UIDevice *device = (UIDevice*)notification.object;
        if ([_controller shouldAutorotate] && (RZOrientationMaskContainsOrientation([_controller supportedInterfaceOrientations], device.orientation))) {
            if(_textLabel){
                self.message = _message;
            }
            else{
                CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame) - [self getOffsetXLeft] - [self getOffsetXRight]];
                [self adjustHeightAndRedraw:height];
            }
            
            CGRect frame = self.frame;
            CGFloat yOrigin = 0.0f;
            
            if (_position == RZNotificationPositionTop) {
                yOrigin = [self _getFinalOriginForPosition:_position];
            }
            else {
                yOrigin = [self _getFinalOriginForPosition:_position]-CGRectGetHeight(self.frame);
            }
            
            frame.origin.y = yOrigin;
            
            if (_controller.view.frame.size.width != 0)
                frame.size.width = _controller.view.frame.size.width;
            self.frame = frame;
            
            _highlightedView.frame = self.bounds;
        }
    }
}

#pragma mark - Touches
- (void) handleTouch
{
    if(!_isTouch){
        _isTouch = YES;
        
        if(_delay == 0.0){
            if (_completionBlock){
                [self hide];
            }
        }
        else{
            [self hide];
        }
    }
}

#pragma mark - UIControl methods

- (void) setHighlighted:(BOOL)highlighted
{
    // Do nothing if no completion block
    if (highlighted != self.highlighted && _completionBlock) { // Avoid to redraw if this is not necessary
        [super setHighlighted:highlighted];
        // We could use Coregraphics to draw different backgrounds, but it means updating the text color etc.
        // So we place a transparent overlay view on top
        if (highlighted) {
            if (!_highlightedView) {
                _highlightedView = [[UIView alloc] init];
                [_highlightedView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
            }
            _highlightedView.frame = self.bounds;
            [self addSubview:_highlightedView];
        }
        else
        {
            [_highlightedView removeFromSuperview];
        }
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    AudioServicesDisposeSystemSoundID(_soundFileObject);
}

@end

static BOOL RZOrientationMaskContainsOrientation(UIInterfaceOrientationMask mask, UIInterfaceOrientation orientation) {
    return (mask & (1 << orientation)) != 0;
}
