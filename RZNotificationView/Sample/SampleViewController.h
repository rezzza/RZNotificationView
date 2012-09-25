//
//  SampleViewController.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SampleViewController : UIViewController
{
    IBOutlet UISlider *_delaySlider;
    IBOutlet UILabel *_delayLabel;
}
- (IBAction) testButtonTop:(id)sender;
- (IBAction) testButtonBottom:(id)sender;
- (IBAction) navBarHidden:(id)sender;
- (IBAction) sliderValueChanged:(id)sender;

@end
