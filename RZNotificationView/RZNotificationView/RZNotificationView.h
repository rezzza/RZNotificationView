//
//  RZNotificationView.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZNotificationLabelProtocol.h"
#include <AudioToolbox/AudioToolbox.h>

#import "UIViewController+RZTopMostController.h"

typedef enum {
    RZNotificationIconFacebook = 0,
    RZNotificationIconGift,
    RZNotificationIconInfo,
    RZNotificationIconSmiley,
	RZNotificationIconTwitter,
    RZNotificationIconWarning
}RZNotificationIcon;

typedef enum {
    RZNotificationPositionTop = 0,
    RZNotificationPositionBottom
}RZNotificationPosition;

typedef enum {
    RZNotificationColorGrey = 0,
    RZNotificationColorYellow,
    RZNotificationColorRed,
    RZNotificationColorBlue
}RZNotificationColor;

typedef enum {
    RZNotificationContentColorAutomaticLight = 0,
    RZNotificationContentColorAutomaticDark,
    RZNotificationContentColorManual
}RZNotificationContentColor;

@class RZNotificationView;

typedef void (^RZNotificationCompletion)(BOOL touched);


@interface RZNotificationView : UIControl
{
    UIImageView *_iconView;
    UIImageView *_anchorView;
    BOOL _isTouch;
    
    SystemSoundID _soundFileObject;
    
}

+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock;

+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock;

+ (RZNotificationView*) showNotificationOnTopMostControllerWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor withCompletion:(RZNotificationCompletion)completionBlock;

+ (RZNotificationView*) showNotificationOnTopMostControllerWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay withCompletion:(RZNotificationCompletion)completionBlock;

+ (BOOL) hideNotificationForController:(UIViewController*)controller;
+ (NSUInteger) hideAllNotificationsForController:(UIViewController*)controller;

+ (RZNotificationView*) notificationForController:(UIViewController*)controller;
+ (NSArray*) allNotificationsForController:(UIViewController*)controller;

- (id) initWithController:(UIViewController*)controller;
- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay completion:(RZNotificationCompletion)completionBlock;


- (void) show;
- (void) hide;
- (void) hideAfterDelay:(NSTimeInterval)delay;

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, strong) id <RZNotificationLabelProtocol> customView;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) RZNotificationPosition position;
@property (nonatomic) RZNotificationColor color;
@property (nonatomic, strong) UIColor *customTopColor;
@property (nonatomic, strong) UIColor *customBottomColor;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic) BOOL vibrate;
@property (nonatomic) RZNotificationContentColor assetColor;
@property (nonatomic) RZNotificationContentColor textColor;
@property (nonatomic) RZNotificationIcon icon;
@property (nonatomic, strong) NSString *customIcon;
@property (nonatomic) BOOL displayAnchor;

@property (nonatomic, strong) RZNotificationCompletion completionBlock;

@end

// define some macros
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif

#if __has_feature(objc_arc) && __clang_major__ >= 3
#define RZ_ARC_ENABLED 1
#endif // __has_feature(objc_arc)

#if RZ_ARC_ENABLED
#define RZ_RETAIN(xx) (xx)
#define RZ_RELEASE(xx)  xx = nil
#define RZ_AUTORELEASE(xx)  (xx)
#else
#define RZ_RETAIN(xx)           [xx retain]
#define RZ_RELEASE(xx)          [xx release], xx = nil
#define RZ_AUTORELEASE(xx)      [xx autorelease]
#endif

#define RZSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
