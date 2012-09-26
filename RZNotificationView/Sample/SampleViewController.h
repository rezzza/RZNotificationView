//
//  SampleViewController.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZNotificationView.h"
#import <QuartzCore/QuartzCore.h>
#import "WEPopoverController.h"
#import "ColorViewController.h"

@interface SampleViewController : UIViewController <RZNotificationViewDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate>
{
    IBOutlet UISlider *_delaySlider;
    IBOutlet UILabel *_delayLabel;
    
    IBOutlet UIView *_topColorView;
    IBOutlet UIView *_bottomColorView;
    
    UIButton *_currentBtn;
}

@property (nonatomic, strong) WEPopoverController *popoverController;

- (IBAction) testButtonTop:(id)sender;
- (IBAction) testButtonBottom:(id)sender;
- (IBAction) navBarHidden:(id)sender;
- (IBAction) sliderValueChanged:(id)sender;

@end
