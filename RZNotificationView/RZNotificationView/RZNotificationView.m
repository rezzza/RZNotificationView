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
#import "UIColor+RZAdditions.h"

#import <AudioToolbox/AudioServices.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define DEFAULT_MAX_MESSAGE_LENGHT 150
#define MIN_HEIGHT 40
#define NOTIFICATION_SHADOW_BLUR_RADIUS 3.0f

#define OFFSET_X 35.0

#define DEFAULT_CONTENT_MARGIN_HEIGHT 8.0f
#define DEFAULT_POSITION RZNotificationPositionTop
#define DEFAULT_DELAY 3.5
#define DEFAULT_COLOR RZNotificationColorBlue
#define DEFAULT_VIBRATE NO
#define DEFAULT_ASSET_COLOR RZNotificationContentColorAutomaticDark
#define DEFAULT_TEXT_COLOR RZNotificationContentColorAutomaticLight
#define DEFAULT_ICON RZNotificationIconFacebook

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
    
    return OFFSET_X - icontWitdhFree;
}

- (CGFloat) getOffsetXRight
{
    CGFloat anchorWitdhFree = 21.0;
    if (_displayAnchor) {
        anchorWitdhFree = 0.0;
    }
    
    return OFFSET_X - anchorWitdhFree;
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
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        [UIColor lighterColorForColor:color withRgbOffset:0.9],
                                        [UIColor lighterColorForColor:color withRgbOffset:0.8], nil];
            iconTrait.shadowColor = [UIColor darkerColorForColor:color withRgbOffset:0.35 andAlphaOffset:0.6];
            iconTrait.innerShadowColor = [UIColor lighterColorForColor:color withRgbOffset:0.88 andAlphaOffset:0.79];
            iconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);
            iconTrait.clipsShadow = NO;
            break;
        case RZNotificationContentColorAutomaticDark:
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        [UIColor darkerColorForColor:color withRgbOffset:0.6],
                                        [UIColor darkerColorForColor:color withRgbOffset:0.4], nil];
            iconTrait.shadowColor = [UIColor lighterColorForColor:color withRgbOffset:0.4 andAlphaOffset:0.6];
            iconTrait.innerShadowColor = [UIColor darkerColorForColor:color withRgbOffset:0.6 andAlphaOffset:0.8];
            iconTrait.shadowOffset = CGSizeMake(0.0f, 1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, 1.0f);
            iconTrait.clipsShadow = NO;
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
    iconView.clipsShadow = YES;
    [iconView mixInTrait:iconTrait];
    
    return [iconView renderImage];
}

- (void) drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* outerShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.75];
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
    CGFloat outerShadowBlurRadius = NOTIFICATION_SHADOW_BLUR_RADIUS;
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
    
    _iconView.frame = CGRectMake(CGRectGetMinX(notificationFrame) + 7,
                                 CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 22) * 0.5) - ceil((_position == RZNotificationPositionTop ? NOTIFICATION_SHADOW_BLUR_RADIUS : -NOTIFICATION_SHADOW_BLUR_RADIUS)/2),
                                 21,
                                 22);
    CGRect contentFrame = CGRectMake(CGRectGetMinX(notificationFrame) + [self getOffsetXLeft],
                                     CGRectGetMinY(notificationFrame) + CGRectGetMinY(notificationFrame) + _contentMarginHeight + (_position == RZNotificationPositionTop ? 0 : NOTIFICATION_SHADOW_BLUR_RADIUS),
                                     CGRectGetWidth(notificationFrame) - [self getOffsetXLeft] - [self getOffsetXRight],
                                     CGRectGetHeight(notificationFrame) - 2*_contentMarginHeight - NOTIFICATION_SHADOW_BLUR_RADIUS);
    _textLabel.frame = contentFrame;
    [_customView setFrame:contentFrame];
    _anchorView.frame = CGRectMake(CGRectGetMinX(notificationFrame) + CGRectGetWidth(notificationFrame) - 26, CGRectGetMinY(notificationFrame) + floor((CGRectGetHeight(notificationFrame) - 22) * 0.5) - ceil((_position == RZNotificationPositionTop ? NOTIFICATION_SHADOW_BLUR_RADIUS : -NOTIFICATION_SHADOW_BLUR_RADIUS)/2), 21, 22);
    

    //// NotificationZone Drawing
    CGRect notificationZoneRect = CGRectMake(CGRectGetMinX(notificationFrame) + 0,
                                             CGRectGetMinY(notificationFrame) + (_position == RZNotificationPositionTop ? 0 : outerShadowBlurRadius),
                                             CGRectGetWidth(notificationFrame) - 0,
                                             CGRectGetHeight(notificationFrame) - (_position == RZNotificationPositionTop ?outerShadowBlurRadius : 0));
    
    CGRect notificationZoneRectExt = CGRectMake(CGRectGetMinX(notificationFrame) + 0,
                                                CGRectGetMinY(notificationFrame) + (_position == RZNotificationPositionTop ? 0 : -outerShadowBlurRadius),
                                                CGRectGetWidth(notificationFrame) - 0,
                                                CGRectGetHeight(notificationFrame) + (_position == RZNotificationPositionTop ? outerShadowBlurRadius : +outerShadowBlurRadius));
    
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
    _anchorView.image = [self image:[UIImage imageNamed:@"notif_anchor.png"] withColor:colorStart];
    if (_textColor != RZNotificationContentColorManual) {
        _textLabel.textColor = [self adjustTextColor:colorStart];
        if(_textColor == RZNotificationContentColorAutomaticDark)
        {
            _textLabel.shadowColor = [UIColor lighterColorForColor:colorStart withRgbOffset:0.4 andAlphaOffset:0.4];
            _textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        }
        else if(_textColor == RZNotificationContentColorAutomaticLight)
        {
            _textLabel.shadowColor = [UIColor darkerColorForColor:colorStart withRgbOffset:0.25 andAlphaOffset:0.4];
            _textLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        }
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
        case RZNotificationIconCustom:
            image = [UIImage imageNamed:_customIcon];
            break;
        case RZNotificationIconNone:
            image = nil;
            break;
        default:
            break;
    }
    return image;
}

- (void) setCustomIcon:(NSString *)customIcon
{
    RZ_RELEASE(_customIcon);
    _customIcon = RZ_RETAIN(customIcon);
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
    RZ_RELEASE(_customTopColor);
    _customTopColor = RZ_RETAIN(customTopColor);
    [self setNeedsDisplay];
}

- (void) setCustomBottomColor:(UIColor *)customBottomColor
{
    RZ_RELEASE(_customBottomColor);
    _customBottomColor = RZ_RETAIN(customBottomColor);
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
    RZ_RELEASE(_message);
    _message = RZ_RETAIN(message);
    
    NSInteger maxLenght = _messageMaxLenght;
    if (maxLenght == 0)
        maxLenght = DEFAULT_MAX_MESSAGE_LENGHT;
    
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
    RZ_RELEASE(_sound);
    _sound = RZ_RETAIN(sound);

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
        RZ_RELEASE(_customView);
        _customView = RZ_RETAIN(customView);
        RZ_RELEASE(_textLabel);
        [self addSubview:(UIView*)_customView];
    }
    else{
        [_customView removeFromSuperview];
        RZ_RELEASE(_customView);
        
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
    
    RZ_RELEASE(_completionBlock);
    _completionBlock = RZ_RETAIN(completionBlock);
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
        _textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
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
        _textLabel.shadowColor = [UIColor whiteColor];
    }
    
    if (!_textLabel.superview)
        [self addSubview:_textLabel];
}

#pragma mark - Init methods

- (id) initWithFrame:(CGRect)frame icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay
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
        _textColor = textColor;
        _icon = icon;
        _displayAnchor = YES;
        _contentMarginHeight = DEFAULT_CONTENT_MARGIN_HEIGHT;
        
        // Add icon view
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.clipsToBounds = NO;
        _iconView.opaque = YES;
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:_iconView];
        
        // Add Anchor view
        _anchorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notif_anchor.png"]];
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
                          icon:DEFAULT_ICON
                      position:DEFAULT_POSITION
                         color:DEFAULT_COLOR
                    assetColor:DEFAULT_ASSET_COLOR
                    textColor:DEFAULT_TEXT_COLOR
                         delay:DEFAULT_DELAY];
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
                                                     delay:DEFAULT_DELAY
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
    return RZ_AUTORELEASE(notification);
}

+ (RZNotificationView *)showNotificationOnTopMostControllerWithMessage:(NSString *)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor withCompletion:(RZNotificationCompletion)completionBlock
{
    
    return [RZNotificationView showNotificationOnTopMostControllerWithMessage:message
                                                                         icon:icon
                                                                     position:position
                                                                        color:color
                                                                   assetColor:assetColor
                                                                    textColor:textColor
                                                                        delay:DEFAULT_DELAY
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
    return RZ_AUTORELEASE(notification);
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
    if (_customView) {
        CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame) - [self getOffsetXLeft] - [self getOffsetXRight]];
        [self adjustHeightAndRedraw:height];
    }
    
    [self placeToOrigin];
    
    _isShowing = YES;
    
    if (_position == RZNotificationPositionTop) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    else{
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    [_controller.view addSubview:self];
    
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
    frame.size.height = MAX(MIN_HEIGHT , height + 2.0*_contentMarginHeight + NOTIFICATION_SHADOW_BLUR_RADIUS);
    self.frame = frame;
    [self setNeedsDisplay];
}

#pragma mark - Rotation handling

- (void) deviceOrientationDidChange:(NSNotification*)notification
{
    if(self.superview){
        if(_textLabel){
            self.message = _message;
        }
        else{
            CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame) - [self getOffsetXLeft] - [self getOffsetXRight]];
            [self adjustHeightAndRedraw:height];
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
        _highlightedView.frame = CGRectOffset(CGRectInset(self.bounds, 0.0, 1.5), 0.0, _position == RZNotificationPositionTop ? -NOTIFICATION_SHADOW_BLUR_RADIUS : NOTIFICATION_SHADOW_BLUR_RADIUS);
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
            _highlightedView.frame = CGRectOffset(CGRectInset(self.bounds, 0.0, 1.5), 0.0, _position == RZNotificationPositionTop ? -NOTIFICATION_SHADOW_BLUR_RADIUS : NOTIFICATION_SHADOW_BLUR_RADIUS);
            [self addSubview:_highlightedView];
        }
        else
        {
            [_highlightedView removeFromSuperview];
            RZ_RELEASE(_highlightedView);
        }
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    AudioServicesDisposeSystemSoundID(_soundFileObject);
    
    RZ_RELEASE(_highlightedView);
    RZ_RELEASE(_controller);
    RZ_RELEASE(_iconView);
    RZ_RELEASE(_anchorView);
    RZ_RELEASE(_textLabel);
    RZ_RELEASE(_message);
    RZ_RELEASE(_customView);
    RZ_RELEASE(_customTopColor);
    RZ_RELEASE(_customBottomColor);
    RZ_RELEASE(_sound);
    RZ_RELEASE(_customIcon);
    if (_completionBlock)
        RZ_RELEASE(_completionBlock);
    
#if !RZ_ARC_ENABLED
    [super dealloc];
#endif
}

@end
