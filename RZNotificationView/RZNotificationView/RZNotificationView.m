//
//  RZNotificationView.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "RZNotificationView.h"

@import AudioToolbox.AudioServices;
@import ObjectiveC.runtime;

#import "UIColor+RZAdditions.h"

#import <MOOMaskedIconView/MOOMaskedIconView.h>
#import <MOOMaskedIconView/MOOStyleTrait.h>

#import <PPHelpMe/PPHelpMe.h>

#define RZUIColorFromRGB(rgbValue) [UIColor               \
colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0f \
green:((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0f           \
blue:((CGFloat)(rgbValue & 0xFF))/255.0f                     \
alpha:1.0f]

#pragma mark -

@protocol RZNotificationViewManagerProtocol <NSObject>
@property (nonatomic, strong) NSMutableArray *rzNotifications;
@end

/**
 *  Default containers for notification view. We could do this on NSObject. Just avoiding to do anything but messing around
 */
@interface UIViewController (RZNotificationViewManager) <RZNotificationViewManagerProtocol>
@end

@interface UIWindow (RZNotificationViewManager) <RZNotificationViewManagerProtocol>
@end

#pragma mark -

@interface RZNotificationViewManager : NSObject

+ (UIWindow *) notificationWindow;

+ (void) registerNotification:(RZNotificationView*)notification;
+ (void) removeNotification:(RZNotificationView*)notification;
+ (RZNotificationView *) notificationForContainer:(id<RZNotificationViewManagerProtocol>)container;
+(NSArray *) allNotificationsForContainer:(id<RZNotificationViewManagerProtocol>)container;
@end

static const NSInteger kDefaultMaxMessageLength            = 150;

static const RZNotificationPosition kDefaultPosition       = RZNotificationPositionTop;
static const RZNotificationColor kDefaultColor             = RZNotificationColorLightBlue;
static const BOOL kDefaultVibrate                          = NO;
static const RZNotificationContentColor kDefaultAssetColor = RZNotificationContentColorDark;
static const RZNotificationContentColor kDefaultTextColor  = RZNotificationContentColorLight;
static const RZNotificationIcon kDefaultIcon               = RZNotificationIconFacebook;
static const RZNotificationAnchor kDefaultAnchor           = RZNotificationAnchorArrow;

static const NSTimeInterval kDefaultDuration               = 3.5;

static CGFloat kMinHeight                                  = 54.0f;
static CGFloat kDefaultContentMarginHeight                 = 16.0f;
static CGFloat kDefaultOffsetX                             = 16.0f;

//static CGFloat kOffsetBetweenTextAndImages           = 16.0f; // If you change this value, please consider add it as static
#define kOffsetBetweenTextAndImages                        kDefaultOffsetX

static const CGFloat kIconWidth                            = 21.0f;
static const CGFloat kIconHeight                           = 22.0f;

static BOOL RZOrientationMaskContainsOrientation(UIInterfaceOrientationMask mask, UIDeviceOrientation orientation);

@interface RZNotificationView ()
{
    BOOL _isShowing;
    BOOL _hasPlayedSound;
    BOOL _hasVibrate;
    
    UIView *_highlightedView;
    
    CGFloat _topOffset; // For below status bar
}
@property (nonatomic, strong) id <RZNotificationViewManagerProtocol> container;
@property (nonatomic, strong) UIViewController *contextController;
@property (nonatomic, assign) RZNotificationContext context;
@end

@implementation RZNotificationView

#pragma mark - Get Offset

- (CGFloat) getOffsetXLeft
{
    CGFloat offsetX = kDefaultOffsetX;
    if ([self getImageForIcon:_icon]) {
        offsetX += (kIconWidth + kOffsetBetweenTextAndImages);
    }
    
    return offsetX;
}

- (CGFloat) getOffsetXRight
{
    CGFloat offsetX = kDefaultOffsetX;
    if ([self getImageForAnchor:_anchor]) {
        offsetX += (kIconWidth + kOffsetBetweenTextAndImages);
    }
    
    return offsetX;
}

#pragma mark - Color Adjustements

- (UIColor*) adjustTextColor:(UIColor*)c
{
    UIColor *colorToReturn = nil;
    switch (_textColor) {
        case RZNotificationContentColorLight:
            colorToReturn = [UIColor whiteColor];
            break;
        case RZNotificationContentColorDark:
            colorToReturn = [UIColor colorWithWhite:76.0f/255.0f alpha:1.0f];
            break;
            // Deprecated
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        case RZNotificationContentColorAutomaticDark:
            colorToReturn = [UIColor darkerColorForColor:c withRgbOffset:0.55f];
            break;
        case RZNotificationContentColorAutomaticLight:
            colorToReturn = [UIColor lighterColorForColor:c withRgbOffset:0.9f];
            break;
#pragma GCC diagnostic pop
            
        default:
            colorToReturn = c;
            break;
    }
    
    return colorToReturn;
}

#pragma mark - Drawings

- (UIImage *)image:(UIImage *)img withColor:(UIColor *)color
{
    MOOStyleTrait *iconTrait = [MOOStyleTrait trait];
    
    switch(_assetColor)
    {
        case RZNotificationContentColorLight:
            iconTrait.color = [UIColor whiteColor];
            break;
        case RZNotificationContentColorDark:
            iconTrait.color = [UIColor colorWithWhite:76.0f/255.0f alpha:1.0f];
            break;
        case RZNotificationContentColorManual:
            NSLog(@"Warning, setting RZNotificationContentColorManual for assetColor is not supported. Setting to textColor");
            if (_textColor != RZNotificationContentColorManual)
                _assetColor = _textColor;
            else
                _assetColor = RZNotificationContentColorLight;
            
            return [self image:img withColor:color];
            break;
   // Deprecated
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        case RZNotificationContentColorAutomaticLight:
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        [UIColor lighterColorForColor:color withRgbOffset:0.9f],
                                        [UIColor lighterColorForColor:color withRgbOffset:0.8f], nil];
            iconTrait.shadowColor = [UIColor darkerColorForColor:color withRgbOffset:0.35f andAlphaOffset:0.6f];
            iconTrait.innerShadowColor = [UIColor lighterColorForColor:color withRgbOffset:0.88f andAlphaOffset:0.79f];
            iconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);
            iconTrait.clipsShadow = NO;
            break;
        case RZNotificationContentColorAutomaticDark:
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        [UIColor darkerColorForColor:color withRgbOffset:0.6f],
                                        [UIColor darkerColorForColor:color withRgbOffset:0.4f], nil];
            iconTrait.shadowColor = [UIColor lighterColorForColor:color withRgbOffset:0.4f andAlphaOffset:0.6f];
            iconTrait.innerShadowColor = [UIColor darkerColorForColor:color withRgbOffset:0.6f andAlphaOffset:0.8f];
            iconTrait.shadowOffset = CGSizeMake(0.0f, 1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, 1.0f);
            iconTrait.clipsShadow = NO;
            break;
#pragma GCC diagnostic pop
    }
    
    MOOMaskedIconView *iconView = [MOOMaskedIconView iconWithImage:img];
    iconView.clipsShadow = YES;
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
            case RZNotificationColorYellow:
                colorStart = RZUIColorFromRGB(0xFFBD00);
                break;
            case RZNotificationColorRed:
                colorStart = RZUIColorFromRGB(0xB20000);
                break;
            case RZNotificationColorLightBlue:
                colorStart = RZUIColorFromRGB(0x3699C9);
                break;
            case RZNotificationColorDarkBlue:
                colorStart = RZUIColorFromRGB(0x395799);
                break;
            case RZNotificationColorPurple:
                colorStart = RZUIColorFromRGB(0x704081);
                break;
            case RZNotificationColorOrange:
                colorStart = RZUIColorFromRGB(0xD35400);
                break;
                // Deprecated
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            case RZNotificationColorGrey:
                colorStart = [UIColor colorWithRed: 162.0f/255.0f green: 156.0f/255.0f blue: 142.0f/255.0f alpha: 1.0f];
                break;
#pragma GCC diagnostic pop
            default:
                colorStart = [UIColor colorWithRed: 162.0f/255.0f green: 156.0f/255.0f blue: 142.0f/255.0f alpha: 1.0f];
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
    _iconView.frame = CGRectMake(0.0f,
                                 CGRectGetMinY(notificationFrame) + _topOffset + (CGFloat)floor((CGRectGetHeight(notificationFrame) - kIconHeight) * 0.5f),
                                 kIconWidth,
                                 kIconHeight);
    _iconView.center = CGPointMake(kDefaultOffsetX + kIconWidth * 0.5f, _iconView.center.y);
    
    CGRect contentFrame = CGRectMake(CGRectGetMinX(notificationFrame) + [self getOffsetXLeft],
                                     CGRectGetMinY(notificationFrame) + kDefaultContentMarginHeight + _topOffset,
                                     CGRectGetWidth(notificationFrame) - [self getOffsetXLeft] - [self getOffsetXRight],
                                     CGRectGetHeight(notificationFrame) - 2*kDefaultContentMarginHeight);
    _textLabel.frame = contentFrame;
    [_customView setFrame:contentFrame];

    _iconView.image = [self image:[self getImageForIcon:_icon] withColor:colorStart];
    _anchorView.image = [self image:[self getImageForAnchor:_anchor] withColor:colorStart];
    [_anchorView setSize:_anchorView.image.size];
    
    _anchorView.frame = CGRectMake(0.0f, CGRectGetMinY(notificationFrame) + _topOffset + (CGFloat)floor((CGRectGetHeight(notificationFrame) - kIconHeight) * 0.5f), kIconWidth, kIconHeight);
    _anchorView.center = CGPointMake(CGRectGetMaxX(notificationFrame) - (kDefaultOffsetX + kIconWidth * 0.5f), _anchorView.center.y);

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
    
    return imageName ? [UIImage imageNamed:imageName] : nil;
}

- (UIImage*) getImageForAnchor:(RZNotificationAnchor)anchor
{
    NSString *imageName = nil;
    switch (anchor) {
        case RZNotificationAnchorArrow:
            imageName = @"notif_anchor_arrow";
            break;
        case RZNotificationAnchorX:
            imageName = @"notif_anchor_cross";
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
    
    _textLabel.text = message; // FIXME: Why? We should keep the truncated text
    
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

- (void)setAnchor:(RZNotificationAnchor)anchor
{
    _anchor = anchor;
    
    if (_anchor != RZNotificationAnchorNone && !_anchorView.superview) {
        [self addSubview:_anchorView];
    }
    else if (_anchor == RZNotificationAnchorNone && _anchorView.superview){
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
        
        if ([_customView shouldHandleTouch] && [_customView isKindOfClass:[UIControl class]]) {
            [((UIControl *)_customView) addTarget:self
                            action:@selector(handleTouch)
                  forControlEvents:UIControlEventTouchUpInside];
        }
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

- (void) setContainer:(id<RZNotificationViewManagerProtocol>)container
{
    NSAssert([container conformsToProtocol:@protocol(RZNotificationViewManagerProtocol)], @"The container should conforms to `RZNotificationViewManagerProtocol`");
    _container = container;
}

- (void) setContext:(RZNotificationContext)context
{
    _context = context;
    if (_context != RZNotificationContextTopMostController) {
        self.contextController = [UIViewController topMostController];
    }
}

#pragma mark - Default configuration

+ (void)registerMinimumHeight:(CGFloat)minimumHeight
{
    kMinHeight = minimumHeight;
}

+ (void)registerContentMarginOnHeight:(CGFloat)contentMarginHeight
{
    kDefaultContentMarginHeight = contentMarginHeight;
}

+ (void)registerDefaultOffsetOnX:(CGFloat)defaultXOffset
{
    kDefaultOffsetX = defaultXOffset;
}

#pragma mark - Subviews build

- (void) addTextLabelIfNeeded
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - [self getOffsetXLeft] - [self getOffsetXRight], 0)];
        _textLabel.numberOfLines = 0;
        _textLabel.font = _labelFont;
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

- (id) initWithFrame:(CGRect)frame icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor duration:(NSTimeInterval)duration
{
    CGRect mFrame = frame;
    mFrame.size.height = MAX(CGRectGetHeight(frame), kMinHeight);
    
    self = [super initWithFrame:mFrame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Set default values
        _delay = duration;
        _position = position;
        _color = color;
        _vibrate = kDefaultVibrate;
        _assetColor = assetColor;
        _textColor = textColor;
        _icon = icon;
        _anchor = anchor;
        _labelFont = [UIFont fontWithName:@"Avenir" size:15.0];
        
        kDefaultContentMarginHeight = kDefaultContentMarginHeight;
        
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
        if (_anchor != RZNotificationAnchorNone)
        {
            [self addSubview:_anchorView];
        }
        
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
                        anchor:kDefaultAnchor
                      position:kDefaultPosition
                         color:kDefaultColor
                    assetColor:kDefaultAssetColor
                     textColor:kDefaultTextColor
                      duration:kDefaultDuration];
}

- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor duration:(NSTimeInterval)duration completion:(RZNotificationCompletion)completionBlock
{
    return [self initWithContainer:controller
                              icon:icon
                            anchor:anchor
                          position:position
                             color:color
                        assetColor:assetColor
                         textColor:textColor
                          duration:duration
                        completion:completionBlock];
}

- (id) initWithContainer:(id<RZNotificationViewManagerProtocol>)container icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor duration:(NSTimeInterval)duration completion:(RZNotificationCompletion)completionBlock;
{
    CGRect frame = self.bounds;
    frame.size.width = CGRectGetWidth(PPScreenBounds());
    
    self = [self initWithFrame:frame
                          icon:icon
                        anchor:anchor
                      position:position
                         color:color
                    assetColor:assetColor
                     textColor:textColor
                      duration:duration];
    if (self)
    {
        self.container = container;
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
        self.container = controller;
    }
    return self;
}

// Freely adapted from MBProgressHUD
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor  textColor:(RZNotificationContentColor)textColor addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock
{
    return [RZNotificationView showNotificationWithMessage:message
                                                      icon:icon
                                                    anchor:anchor
                                                  position:position
                                                     color:color
                                                assetColor:assetColor
                                                 textColor:textColor
                                                  duration:kDefaultDuration
                                         addedToController:controller
                                            withCompletion:completionBlock];
}

+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor duration:(NSTimeInterval)duration addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock;
{
    RZNotificationView *notification = [[RZNotificationView alloc] initWithController:controller
                                                                                 icon:icon
                                                                               anchor:anchor
                                                                             position:position
                                                                                color:color
                                                                           assetColor:assetColor
                                                                            textColor:textColor
                                                                             duration:duration
                                                                           completion:completionBlock];
    [notification setMessage:message];
    [notification show];
    return notification;
}

+ (RZNotificationView*) showNotificationOn:(RZNotificationContext)context message:(NSString*)message icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor withCompletion:(RZNotificationCompletion)completionBlock
{
    
    return [RZNotificationView showNotificationOn:context
                                          message:message
                                             icon:icon
                                           anchor:anchor
                                         position:position
                                            color:color
                                       assetColor:assetColor
                                        textColor:textColor
                                         duration:kDefaultDuration
                                   withCompletion:completionBlock];
}

+ (RZNotificationView*) showNotificationOn:(RZNotificationContext)context message:(NSString*)message icon:(RZNotificationIcon)icon anchor:(RZNotificationAnchor)anchor position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor duration:(NSTimeInterval)duration withCompletion:(RZNotificationCompletion)completionBlock
{
    RZNotificationView *notification = [[RZNotificationView alloc] initWithContainer:[self containerForContext:context]
                                                                                icon:icon
                                                                              anchor:anchor
                                                                            position:position
                                                                               color:color
                                                                          assetColor:assetColor
                                                                           textColor:textColor
                                                                            duration:duration
                                                                          completion:completionBlock];
    [notification setContext:context];
    [notification setMessage:message];
    [notification show];
    return notification;
}

+ (id<RZNotificationViewManagerProtocol>)containerForContext:(RZNotificationContext)context
{
    id <RZNotificationViewManagerProtocol> toReturn = nil;
    switch (context) {
        case RZNotificationContextTopMostController:
            toReturn = [UIViewController topMostController];
            break;
            case RZNotificationContextAboveStatusBar:
            case RZNotificationContextBelowStatusBar:
            toReturn = [RZNotificationViewManager notificationWindow];
        default:
            break;
    }
    return toReturn;
}

+ (BOOL) hideLastNotificationForController:(UIViewController*)controller
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
    return [RZNotificationViewManager notificationForContainer:controller];
}

+ (NSArray*) allNotificationsForController:(UIViewController*)controller
{
    return [RZNotificationViewManager allNotificationsForContainer:controller];
}

#pragma mark - Show hide methods
- (CGFloat) _getFinalOriginForPosition:(RZNotificationPosition)position
{
    CGFloat finalOrigin = 0.0f;
    
    if ([_container isKindOfClass:[UIViewController class]]) {
        UIViewController *c = (UIViewController*)_container;
        
        if ([c conformsToProtocol:@protocol(RZNotificationViewProtocol)] && [c respondsToSelector:@selector(yOriginForRZNotificationViewForPosition:)]) {
            finalOrigin = [(UIViewController<RZNotificationViewProtocol>*)c yOriginForRZNotificationViewForPosition:position];
        } else {
            if (position == RZNotificationPositionTop) {
                finalOrigin = [c.topLayoutGuide length];
            } else {
                finalOrigin = CGRectGetHeight(c.view.frame) - [c.bottomLayoutGuide length];
            }
        }
    }
    else
    {
        UIView *v = (UIView*)_container;
        
        if (position == RZNotificationPositionTop) {
            finalOrigin = 0.0f;
        } else {
            finalOrigin = CGRectGetHeight(v.frame);
        }
    }
    
    return finalOrigin;
}

- (void) placeToOrigin
{
    CGFloat yOrigin = 0.0f;
    UIView *view = nil;
    if ([_container isKindOfClass:[UIViewController class]]) {
        view = [(UIViewController*)_container view];
    }
    else {
        view = (UIView*)_container;
    }
    
    if (_position == RZNotificationPositionTop) {
        yOrigin = -CGRectGetHeight(self.frame);
    }
    else {
        yOrigin = CGRectGetHeight(view.frame);
    }
    
    [self setYOrigin:yOrigin];
}

- (void) placeToFinalPosition
{
    CGFloat yFinalOrigin = 0.0f;
    
    if (_position == RZNotificationPositionTop) {
        yFinalOrigin = [self _getFinalOriginForPosition:_position];
    } else {
        yFinalOrigin = [self _getFinalOriginForPosition:_position] - CGRectGetHeight(self.frame);
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
    
    if ([_container isKindOfClass:[UIViewController class]]) {
        UIViewController *c = (UIViewController*)_container;
        if ([c conformsToProtocol:@protocol(RZNotificationViewProtocol)] && [c respondsToSelector:@selector(addRZNotificationView:)]) {
            [(UIViewController<RZNotificationViewProtocol>*)c addRZNotificationView:self];
        } else {
            [c.view addSubview:self];
        }
    }
    else
    {
        NSAssert([_container respondsToSelector:@selector(addSubview:)], @"Your container should at least responds to `addSubview:`");
        UIWindow *w = (UIWindow*)_container;
        
        if (self.context == RZNotificationContextAboveStatusBar) {
            w.windowLevel = UIWindowLevelStatusBar + 1.0f;
        }
        else {
            w.windowLevel = UIWindowLevelNormal;
        }
        
        [w setSize:self.bounds.size];
    
        if (_position == RZNotificationPositionTop) {
            [w setOrigin:CGPointZero];
        }
        else {
            [w setOrigin:CGPointMake(0.0f, CGRectGetHeight(PPScreenBounds()) - CGRectGetHeight(w.bounds))];
        }
        
        [_container performSelector:@selector(addSubview:) withObject:self];
        w.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
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
    
    [RZNotificationViewManager registerNotification:self];
    
    self.hidden = NO;
    [UIView animateWithDuration:0.4
                     animations:^{
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
                         [RZNotificationViewManager removeNotification:self];
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
    
    if (_context == RZNotificationContextBelowStatusBar && _position == RZNotificationPositionTop) {
        _topOffset = PPStatusBarHeight() / 2.0f;
    }
    else {
        _topOffset = 0.0f;
    }
    
    frame.size.height = MAX(kMinHeight , height + 2.0f*kDefaultContentMarginHeight + _topOffset);
    self.frame = frame;
    [self setNeedsDisplay];
}

#pragma mark - Rotation handling

- (void) deviceOrientationDidChange:(NSNotification*)notification
{
    if(self.superview){
        if ([_container isKindOfClass:[UIViewController class]]) {
            UIViewController *c = (UIViewController*)_container;

            UIDevice *device = (UIDevice*)notification.object;
            if ([c shouldAutorotate] && (RZOrientationMaskContainsOrientation([c supportedInterfaceOrientations], device.orientation))) {
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
                
                if (c.view.frame.size.width != 0)
                    frame.size.width = c.view.frame.size.width;
                self.frame = frame;
                
                _highlightedView.frame = self.bounds;
            }
        }
        else
        {
            // TODO: handle rotation for window
            NSLog(@"Handle rotation: TODO :/");
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
                [_highlightedView setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.3f]];
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

#pragma mark - deprecated

- (void) setContentMarginHeight:(CGFloat)contentMarginHeight
{
    kDefaultContentMarginHeight = contentMarginHeight;
    
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


- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay completion:(RZNotificationCompletion)completionBlock;
{
    return [self initWithController:controller icon:icon anchor:RZNotificationAnchorArrow position:position color:color assetColor:assetColor textColor:textColor duration:delay completion:completionBlock];
}

+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor  textColor:(RZNotificationContentColor)textColor addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock
{
    return [RZNotificationView showNotificationWithMessage:message
                                                      icon:icon
                                                  position:position
                                                     color:color
                                                assetColor:assetColor
                                                 textColor:textColor
                                                     delay:kDefaultDuration
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
                                                                        delay:kDefaultDuration
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
    return [self hideLastNotificationForController:controller];
}

@end


#pragma mark - Notification Manager

@implementation UIViewController (RZNotificationViewManager)
static char rzNotificationsKey;

- (void)setRzNotifications:(NSMutableArray *)rzNotifications
{
    objc_setAssociatedObject(self,
                             &rzNotificationsKey,
                             rzNotifications,
                             OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *) rzNotifications {
    id notifications = objc_getAssociatedObject(self,
                                             &rzNotificationsKey);
    
    if (!notifications)
    {
        notifications = [NSMutableArray array];
        self.rzNotifications = notifications;
    }
    return notifications;
}

@end

@implementation UIWindow (RZNotificationViewManager)
static char rzNotificationsKey;

- (void)setRzNotifications:(NSMutableArray *)rzNotifications
{
    objc_setAssociatedObject(self,
                             &rzNotificationsKey,
                             rzNotifications,
                             OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *) rzNotifications {
    id notifications = objc_getAssociatedObject(self,
                                                &rzNotificationsKey);
    
    if (!notifications)
    {
        notifications = [NSMutableArray array];
        self.rzNotifications = notifications;
    }
    return notifications;
}

@end

@implementation RZNotificationViewManager

+ (UIWindow *)notificationWindow
{
    static dispatch_once_t pred = 0;
    __strong static UIWindow *_notificationWindow = nil;
    dispatch_once(&pred, ^{
        _notificationWindow = [[UIWindow alloc] initWithFrame:PPScreenBounds()];
        _notificationWindow.hidden = YES;
    });
    return _notificationWindow;
}

+ (void)registerNotification:(RZNotificationView *)notification
{
    NSAssert(notification, @"`notification should not be nil`");
    [notification.container.rzNotifications addObject:notification];
    
    if ([notification.container isEqual:[self notificationWindow]]) {
        [[self notificationWindow] setHidden:NO];
    }
}

+ (void)removeNotification:(RZNotificationView*)notification
{
    NSAssert(notification, @"`notification should not be nil`");
    if ([notification.container.rzNotifications containsObject:notification]) {
        [notification.container.rzNotifications removeObject:notification];
    }
    
    if ([notification.container isEqual:[self notificationWindow]]) {
        if ([notification.container.rzNotifications count] == 0) {
            [[self notificationWindow] setHidden:YES];
        }
    }
}

+ (RZNotificationView *)notificationForContainer:(id<RZNotificationViewManagerProtocol>)container
{
    NSAssert([container conformsToProtocol:@protocol(RZNotificationViewManagerProtocol)], @"The container should conforms to `RZNotificationViewManagerProtocol`");
    
    if([container isKindOfClass:[UIViewController class]])
    {
        // Then we assume that there may be some notifications into a window with a context controller
        NSArray *allNotifsForWindow = [self allNotificationsForContainer:[self notificationWindow]];
        NSArray *filtered = [allNotifsForWindow filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contextController == %@", container]];
        // We also assume that what is on window is on top
        if([filtered count] != 0)
        {
            return [filtered lastObject];
        }
    }
    
    return [container.rzNotifications lastObject];
}

+(NSArray *)allNotificationsForContainer:(id<RZNotificationViewManagerProtocol>)container
{
    NSAssert([container conformsToProtocol:@protocol(RZNotificationViewManagerProtocol)], @"The container should conforms to `RZNotificationViewManagerProtocol`");
    NSMutableArray *toReturn = container.rzNotifications;
    if([container isKindOfClass:[UIViewController class]])
    {
        // Then we assume that there may be some notifications into a window with a context controller
        NSArray *allNotifsForWindow = [self allNotificationsForContainer:[self notificationWindow]];
        [toReturn addObjectsFromArray:allNotifsForWindow];
    }

    return [NSArray arrayWithArray:toReturn];
}

@end

static BOOL RZOrientationMaskContainsOrientation(UIInterfaceOrientationMask mask, UIDeviceOrientation orientation) {
    
    UIInterfaceOrientation iOrientation = UIInterfaceOrientationPortrait;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            iOrientation = UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            iOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            iOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            iOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
    
    return (mask & (1 << iOrientation)) != 0;
}
