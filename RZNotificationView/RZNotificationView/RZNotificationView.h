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

/**
 @enum RZNotificationIcon
 The icon to display
 */
typedef enum {
    /** Facebook icon*/
    RZNotificationIconFacebook = 0,
    /** Gift icon*/
    RZNotificationIconGift,
    /** Info icon*/
    RZNotificationIconInfo,
    /** Smiley icon*/
    RZNotificationIconSmiley,
    /** Twitter icon*/
	RZNotificationIconTwitter,
    /** Warning icon*/
    RZNotificationIconWarning,
    /** Custom icon*/
    RZNotificationIconCustom,
    /** No icon*/
    RZNotificationIconNone
}RZNotificationIcon;

/**
 @enum RZNotificationPosition
 The positon of the notification view
 */
typedef enum {
    /** The notification is displayed on top */
    RZNotificationPositionTop = 0,
    /** The notification is displayed on bottom */
    RZNotificationPositionBottom
}RZNotificationPosition;

/**
 @enum RZNotificationColor
 The color of the notification view
 */
typedef enum {
    /** Grey color*/
    RZNotificationColorGrey = 0,
    /** Yellow color*/
    RZNotificationColorYellow,
    /** Red color*/
    RZNotificationColorRed,
    /** Blue color*/
    RZNotificationColorBlue
}RZNotificationColor;

/**
 @enum RZNotificationContentColor
 The color of the notification view content
 */
typedef enum {
    /** Text is automatically lighter */
    RZNotificationContentColorAutomaticLight = 0,
    /** Text is automatically darker */
    RZNotificationContentColorAutomaticDark,
    /** Text color is set with textColor*/
    RZNotificationContentColorManual
}RZNotificationContentColor;


@class RZNotificationView;

typedef void (^RZNotificationCompletion)(BOOL touched);

@protocol RZNotificationViewProtocol

- (CGFloat)yOriginForRZNotificationViewForPosition:(RZNotificationPosition)position;
- (void)addRZNotificationView:(RZNotificationView*)view;

@end

/** Display a Notification easily
 
 This view allow you to display in app notification with a few lines of code
 
 # Show a tweet
 
    [RZNotificationView showNotificationOnTopMostControllerWithMessage:@"This is a twitter message!"
                                                                  icon:RZNotificationIconTwitter
                                                              position:RZNotificationPositionTop
                                                                 color:RZNotificationColorYellow
                                                            assetColor:RZNotificationContentColorAutomaticLight
                                                             textColor:RZNotificationContentColorAutomaticDark
                                                        withCompletion:nil];
 
 # Show a warning with custom sound and vibration
 
    RZNotificationView *notif = [RZNotificationView showNotificationWithMessage:@"Warning, you did something wrong."
                                                                           icon:RZNotificationIconWarning
                                                                       position:RZNotificationPositionTop
                                                                          color:RZNotificationColorRed
                                                                     assetColor:RZNotificationContentColorAutomaticDark
                                                                      textColor:RZNotificationContentColorAutomaticLight
                                                              addedToController:self
                                                                 withCompletion:nil];
    [notif setSound:@"DoorBell-SoundBible.com-1986366504.wav"];
    [notif setVibrate:YES];

 # Show a facebook invitation
 
     [RZNotificationView showNotificationWithMessage:@"Tell your friends that RZNotificationView is awesome."
                                                icon:RZNotificationIconFacebook
                                            position:RZNotificationPositionBottom
                                               color:RZNotificationColorBlue
                                          assetColor:RZNotificationContentColorAutomaticDark
                                           textColor:RZNotificationContentColorAutomaticLight
                                   addedToController:self
                                      withCompletion:^(BOOL touched) {
                                             if (touched) {
                                                NSURL *fbURL = [NSURL URLWithString:@"fb://"];
                                                if ([[UIApplication sharedApplication] canOpenURL:fbURL]) {
                                                    [[UIApplication sharedApplication] openURL:fbURL];
                                                }
                                                else
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com"]];
                                             }
                                        }];

 
 */
@interface RZNotificationView : UIControl
{
    UIImageView *_anchorView;
    BOOL _isTouch;
    
    SystemSoundID _soundFileObject;
    
}

/**---------------------------------------------------------------------------------------
 * @name Showing methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Show a notification on a specific controller
 @param message The message
 @param icon The icon
 @param position The position
 @param color The notification color
 @param assetColor The asset color
 @param textColor The text color
 @param controller The specific controller that display the notification
 @param completionBlock The completionBlock to execute
 @return RZNotificationView intialized by given parameters
 */
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock;

/**
 Show a notification on a specific controller with delay
 @param message The message
 @param icon The icon
 @param position The position
 @param color The notification color
 @param assetColor The asset color
 @param textColor The text color
 @param delay The delay before hiding the notification view
 @param controller The specific controller that display the notification
 @param completionBlock The completionBlock to execute
 @return RZNotificationView intialized by given parameters
 */
+ (RZNotificationView*) showNotificationWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay addedToController:(UIViewController*)controller withCompletion:(RZNotificationCompletion)completionBlock;

/**
 Show a notification on top most controller (the controller currently displayed)
 @param message The message
 @param icon The icon
 @param position The position
 @param color The notification color
 @param assetColor The asset color
 @param textColor The text color
 @param completionBlock The completionBlock to execute
 @return RZNotificationView intialized by given parameters
 */
+ (RZNotificationView*) showNotificationOnTopMostControllerWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor withCompletion:(RZNotificationCompletion)completionBlock;

/**
 Show a notification on top most controller (the controller currently displayed)
 @param message The message
 @param icon The icon
 @param position The position
 @param color The notification color
 @param assetColor The asset color
 @param textColor The text color
 @param delay The delay before hiding the notification view
 @param completionBlock The completionBlock to execute
 @return RZNotificationView intialized by given parameters
 */
+ (RZNotificationView*) showNotificationOnTopMostControllerWithMessage:(NSString*)message icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay withCompletion:(RZNotificationCompletion)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Showing methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Hide notification view for a specific controller
 @param controller The controller expected to display a notification
 @return YES if a notification has been hidden, NO if there wasn't any notification view on controller
 */
+ (BOOL) hideNotificationForController:(UIViewController*)controller;

/**
 Hide all notifications view for a specific controller
 @param controller The controller expected to display a notification
 @return noumber of notifications hidden
 */
+ (NSUInteger) hideAllNotificationsForController:(UIViewController*)controller;

/**---------------------------------------------------------------------------------------
 * @name Init methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Init an empty notification view
 @param controller The controller expected to display a notification
 */
- (id) initWithController:(UIViewController*)controller;

/**
 Init a notification view for a specific controller without displaying it
 You should use this method when you want to use a customView instead of the textLabel
 @param controller The controller expected to display a notification
 @param icon The icon
 @param position The position
 @param color The notification color
 @param assetColor The asset color
 @param textColor The text color
 @param delay The delay before hiding the notification view
 @param completionBlock The completionBlock to execute
 return the notification view initialized
 */
- (id) initWithController:(UIViewController*)controller icon:(RZNotificationIcon)icon position:(RZNotificationPosition)position color:(RZNotificationColor)color assetColor:(RZNotificationContentColor)assetColor textColor:(RZNotificationContentColor)textColor delay:(NSTimeInterval)delay completion:(RZNotificationCompletion)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Other methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Allow to show the notification
 */
- (void) show;

/**
 Allow to hide the notification
 */
- (void) hide;

/**
 Allow to hide the notification after a delay
 @param delay delay in seconds
 */
- (void) hideAfterDelay:(NSTimeInterval)delay;

/**
 get the notificationView displayed on a specific controller
 @param controller The controller expected to display a notification
 */
+ (RZNotificationView*) notificationForController:(UIViewController*)controller;

/**
 get the all notificationViews displayed on a specific controller
 @param controller The controller expected to display a notification
 */
+ (NSArray*) allNotificationsForController:(UIViewController*)controller;

/**---------------------------------------------------------------------------------------
 * @name Properties
 *  ---------------------------------------------------------------------------------------
 */

/**
 Getter for the textLabel
 This label display the message in case you don't use a customView
 */
@property (nonatomic, readonly) UILabel *textLabel;

/**
 Your customView
 - You can set your own view instead of a classic label
 - Your view has to coform to 
 - Have a look on samples
 */
@property (nonatomic, strong) id <RZNotificationLabelProtocol> customView;

/**
 Message to display in cas you use textLabel
 */
@property (nonatomic, strong) NSString *message;

/**
 Delay in seconds before hiding a notification view.
 It won't be hiddend if delay is Equal 0
 */
@property (nonatomic) NSTimeInterval delay;

/**
 Position of notification view
 */
@property (nonatomic) RZNotificationPosition position;

/**
 Background color of notification view if customTopColor and customBottomColor are not used
 */
@property (nonatomic) RZNotificationColor color;

/**
 Top color for background gradient color
 */
@property (nonatomic, strong) UIColor *customTopColor;

/**
 Botton color for background gradient color
 */
@property (nonatomic, strong) UIColor *customBottomColor;

/**
 Sound file name
 */
@property (nonatomic, strong) NSString *sound;

/**
 Activate or not the vibration
 */
@property (nonatomic) BOOL vibrate;

/**
 Color for icon background 
 */
@property (nonatomic) RZNotificationContentColor assetColor;

/**
 Text color
 */
@property (nonatomic) RZNotificationContentColor textColor;

/**
 Icon to display
 */
@property (nonatomic) RZNotificationIcon icon;

/**
 Icon filename for custom image
 */
@property (nonatomic, strong) NSString *customIcon;

/**
 Display or not the anchor (right image)
 */
@property (nonatomic) BOOL displayAnchor;

/**
 Adjust margin on top and botton of textLabel or customView. (8px by default)
 */
@property (nonatomic) CGFloat contentMarginHeight;

/**
 Set the message lenght max you want to display. 3 char "..." will be added. Defaut value is 150
 */
@property (nonatomic) NSInteger messageMaxLenght;

/**
 completionBlock to execute before hiding. Ability to kwon if notification view as been touched or not
 */
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
