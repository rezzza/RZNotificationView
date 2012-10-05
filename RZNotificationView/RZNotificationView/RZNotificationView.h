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

#define RZSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)

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
    RZNotificationTextColorManual = 0,
    RZNotificationTextColorAutomaticLight,
    RZNotificationTextColorAutomaticDark
}RZNotificationTextColor;

typedef enum {
    RZNotificationAssetColorAutomaticLight = 0,
    RZNotificationAssetColorAutomaticDark
}RZNotificationAssetColor;

@protocol RZNotificationViewDelegate;

@interface RZNotificationView : UIControl
{
    UIImageView *_iconView;
    UIImageView *_anchorView;
    BOOL _isTouch;
    
    NSURL *_soundFileURLRef;
    SystemSoundID	soundFileObject;
    
}

+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor addedToController:(UIViewController*)controller;
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor  textColor:(RZNotificationTextColor)textColor addedToController:(UIViewController*)controller;
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor delay:(NSTimeInterval)delay addedToController:(UIViewController*)controller;
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor textColor:(RZNotificationTextColor)textColor delay:(NSTimeInterval)delay addedToController:(UIViewController*)controller;


+ (BOOL) hideNotificationForController:(UIViewController*)controller;
+ (NSUInteger) hideAllNotificationsForController:(UIViewController*)controller;

+ (RZNotificationView*) notificationForController:(UIViewController*)controller;
+ (NSArray*) allNotificationsForController:(UIViewController*)controller;

- (id) initWithController:(UIViewController*)controller;
- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor delay:(NSTimeInterval)delay;
- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationAssetColor)assetColor textColor:(RZNotificationTextColor)textColor delay:(NSTimeInterval)delay;


- (void) show;
- (void) hide;
- (void) hideAfterDelay:(NSTimeInterval)delay;

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, strong) id <RZNotificationLabelProtocol> customView;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) RZNotificationPosition position;
@property (nonatomic) RZNotificationColor color;
@property (nonatomic) UIColor *customTopColor;
@property (nonatomic) UIColor *customBottomColor;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic) BOOL vibrate;
@property (nonatomic) RZNotificationAssetColor assetColor;
@property (nonatomic) RZNotificationTextColor textColor;
@property (nonatomic) RZNotificationIcon icon;
@property (nonatomic, strong) NSString *customIcon;
@property (assign, nonatomic) id <RZNotificationViewDelegate> delegate;
@property (nonatomic, strong) id paramOnAction;

@property (nonatomic, strong) NSURL *urlToOpen;

@end

@protocol RZNotificationViewDelegate <NSObject>
// FIXME: Is it relevant now ?
- (void) notificationViewTouched:(RZNotificationView*)notificationView;
@end
