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
    RZNotificationAssetColorManual = 0,
    RZNotificationAssetColorAutomaticLight,
    RZNotificationAssetColorAutomaticDark
}RZNotificationAssetColor;

@protocol RZNotificationViewDelegate;

@interface RZNotificationView : UIView
{
    UIImageView *_iconView;
    UILabel *_textLabel;
    UIImageView *_anchorView;
    UIViewController *_controller;
    BOOL _isTouch;
    id _actionParam;
    
    NSURL *_soundFileURLRef;
    SystemSoundID	soundFileObject;

}

- (id) initWithMessage:(NSString*)message;
- (void) showFromController:(UIViewController *)controller;
- (void) setActionToCall:(SEL)actionToCall withParam:(id)param;
- (void) close;

@property (nonatomic, strong) UILabel *_textLabel;
@property (nonatomic, strong) id <RZNotificationLabelProtocol> customView;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) float delay;
@property (nonatomic) RZNotificationPosition position;
@property (nonatomic) RZNotificationColor color;
@property (nonatomic) UIColor *customTopColor;
@property (nonatomic) UIColor *customBottomColor;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic) BOOL vibrate;
@property (nonatomic) RZNotificationAssetColor assetColor;
@property (nonatomic) RZNotificationIcon icon;
@property (nonatomic, strong) NSString *customIcon;
@property (assign, nonatomic) id <RZNotificationViewDelegate> delegate;
@property (nonatomic) SEL actionToCall;
@property (nonatomic, strong) NSURL *urlToOpen;

@end

@protocol RZNotificationViewDelegate <NSObject>
- (void) notificationViewTouched:(RZNotificationView*)notificationView;
@end
