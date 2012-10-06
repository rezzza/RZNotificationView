//
//  SimpleSampleViewController.h
//  RZNotificationView
//
//  Created by Marian Paul on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BButton;

@interface SimpleSampleViewController : UIViewController
{
    
    __weak IBOutlet BButton *_twitterButton;
    __weak IBOutlet BButton *_facebookButton;
    __weak IBOutlet BButton *_warningButton;
}

- (IBAction)showTwitter:(id)sender;
- (IBAction)showWarning:(id)sender;
- (IBAction)showFacebook:(id)sender;
- (IBAction)hideAllNotifications:(id)sender;
- (IBAction)presentModalView:(id)sender;

@end
