//
//  RZNotificationView.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@protocol RZNotificationViewDelegate;

@interface RZNotificationView : UIView
{
    UIImageView *_iconView;
    UILabel *_textLabel;
    
    BOOL _isTouch;
}

- (id) initWithMessage:(NSString*)message;
- (void) showFromController:(UIViewController *)controller;
- (void) close;

@property (nonatomic, strong) NSString *message;
@property (nonatomic) float delay;
@property (nonatomic) RZNotificationPosition position;
@property (nonatomic) RZNotificationColor color;
@property (nonatomic) UIColor *customTopColor;
@property (nonatomic) UIColor *customBottomColor;
@property (nonatomic, strong) NSString *sound;
@property (nonatomic) BOOL vibrate;
@property (nonatomic) RZNotificationIcon icon;
@property (nonatomic, strong) NSString *customIcon;
@property (assign, nonatomic) id <RZNotificationViewDelegate> delegate;

@end

@protocol RZNotificationViewDelegate <NSObject>
- (void) notificationViewTouched:(RZNotificationView*)notificationView;
@end
