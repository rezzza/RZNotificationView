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
{
    BOOL _isShowing;
    BOOL _hasPlayedSound;
    BOOL _hasVibrate;
    
    UIView *_highlightedView;
}
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

// From BButton
- (UIColor *)lighterColorForColor:(UIColor *)oldColor withOffset:(CGFloat)value
{
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[1] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[2] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[1] = oldComponents[1]+value > 1.0 ? 1.0 : oldComponents[1]+value;
        newComponents[2] = oldComponents[2]+value > 1.0 ? 1.0 : oldComponents[2]+value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}
- (UIColor *)lighterColorForColor:(UIColor *)c
{
    return [self lighterColorForColor:c withOffset:0.6f];
}

- (UIColor *)darkerColorForColor:(UIColor *)oldColor withOffset:(float)value
{
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[1] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[2] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0]-value < 0.0 ? 0.0 : oldComponents[0]-value;
        newComponents[1] = oldComponents[1]-value < 0.0 ? 0.0 : oldComponents[1]-value;
        newComponents[2] = oldComponents[2]-value < 0.0 ? 0.0 : oldComponents[2]-value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;

}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    return [self darkerColorForColor:c withOffset:0.3f];
}

#pragma mark - Drawings

- (UIImage *)image:(UIImage *)img withColor:(UIColor *)color
{
    MOOStyleTrait *iconTrait = [MOOStyleTrait trait];
    
    switch(_assetColor)
    {
        case RZNotificationAssetColorAutomaticLight:
        {
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        [self lighterColorForColor:color withOffset:0.8],
                                        [self lighterColorForColor:color withOffset:0.7], nil];
            iconTrait.shadowColor = [self darkerColorForColor:color withOffset:0.8];
            iconTrait.innerShadowColor = [self darkerColorForColor:color];
            iconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);
        }
            break;
        case RZNotificationAssetColorAutomaticDark:
        {
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        [self darkerColorForColor:color withOffset:0.3],
                                        [self darkerColorForColor:color withOffset:0.2], nil];
            iconTrait.shadowColor = [self lighterColorForColor:color withOffset:0.4];
            iconTrait.innerShadowColor = [self lighterColorForColor:color withOffset:0.8];
            iconTrait.shadowOffset = CGSizeMake(0.0f, 1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, 1.0f);
        }
            break;
        case RZNotificationAssetColorManual:
        {
            iconTrait.gradientColors = [NSArray arrayWithObjects:
                                        _textLabel.textColor, nil];
            iconTrait.shadowColor = _textLabel.shadowColor;
            iconTrait.innerShadowColor = [self lighterColorForColor:_textLabel.textColor withOffset:0.8];
            iconTrait.shadowOffset = CGSizeMake(0.0f, 1.0f);
            iconTrait.innerShadowOffset = CGSizeMake(0.0f, 1.0f);
        }
            break;
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
    _anchorView.image = [self image:[UIImage imageNamed:@"notif_anchor.png"] withColor:colorStart];
    if (_assetColor != RZNotificationAssetColorManual) {
        _textLabel.textColor = [self adjustAssetsColor:colorStart];
        if(_assetColor == RZNotificationAssetColorAutomaticDark)
            _textLabel.shadowColor = [self lighterColorForColor:colorStart withOffset:0.2];
        if(_assetColor == RZNotificationAssetColorAutomaticLight)
            _textLabel.shadowColor = [self darkerColorForColor:colorStart withOffset:0.8];
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
    
    [self adjustHeightAndRedraw:CGRectGetHeight(_textLabel.frame)];
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
    
    if (_isShowing && !_hasPlayedSound && sound) {
        // Then we play the sound for the first time
        // This happens when you use [RZNotificationView showNotification ...]
        AudioServicesPlaySystemSound (soundFileObject);
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

- (void) adjustHeightAndRedraw:(CGFloat)height
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
        _anchorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notif_anchor.png"]];
        _anchorView.contentMode = UIViewContentModeCenter;
        _anchorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
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
        CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame)-2*OFFSET_X];
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
        AudioServicesPlaySystemSound (soundFileObject);
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

#pragma mark - Rotation handling

- (void) deviceOrientationDidChange:(NSNotification*)notification
{
    if(self.superview){
        if(_textLabel){
            self.message = _message;
        }
        else{
            CGFloat height = [_customView resizeForWidth:CGRectGetWidth(self.frame)-2*OFFSET_X];
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
        _highlightedView.frame = CGRectOffset(CGRectInset(self.bounds, 0.0, 1.5), 0.0, _position == RZNotificationPositionTop ? -3.0 : 3.0);
    }
}

#pragma mark - Touches
- (void) handleTouch
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
    
    if (_urlToOpen) {
        if ([[UIApplication sharedApplication] canOpenURL:_urlToOpen]) {
            [[UIApplication sharedApplication] openURL:_urlToOpen];
        }
    }
}

#pragma mark - UIControl methods

- (void) setHighlighted:(BOOL)highlighted
{
    if (highlighted != self.highlighted) { // Avoid to redraw if this is not necessary
        [super setHighlighted:highlighted];
        // We could use Coregraphics to draw different backgrounds, but it means updating the text color etc.
        // So we place a transparent overlay view on top
        if (highlighted) {
            if (!_highlightedView) {
                _highlightedView = [[UIView alloc] init];
                [_highlightedView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
            }
            _highlightedView.frame = CGRectOffset(CGRectInset(self.bounds, 0.0, 1.5), 0.0, _position == RZNotificationPositionTop ? -3.0 : 3.0);
            [self addSubview:_highlightedView];
        }
        else
            [_highlightedView removeFromSuperview];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
