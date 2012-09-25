//
//  SampleViewController.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "SampleViewController.h"
#import "RZNotificationView.h"

@interface SampleViewController ()

@end

@implementation SampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _delaySlider.value = 2.0;
    _delayLabel.text = [NSString stringWithFormat:@"delay : %.1f", _delaySlider.value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button clic

- (IBAction) testButtonTop:(id)sender
{
    RZNotificationView *notifView = [[RZNotificationView alloc] initWithMessage:@"Le test TOP"];
    notifView.icon = RZNotificationIconFacebook;
    notifView.delay = _delaySlider.value;
    notifView.position = RZNotificationPositionTop;
    [notifView showFromController:self];
}

- (IBAction) testButtonBottom:(id)sender
{
    RZNotificationView *notifView = [[RZNotificationView alloc] initWithMessage:@"Le test BOTTOM"];
    notifView.icon = RZNotificationIconSmiley;
    notifView.delay = _delaySlider.value;
    notifView.position = RZNotificationPositionBottom;
    notifView.color = RZNotificationColorBlue;
    [notifView showFromController:self];
}

- (IBAction) navBarHidden:(id)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (IBAction) sliderValueChanged:(id)sender
{
    _delayLabel.text = [NSString stringWithFormat:@"delay : %.1f", _delaySlider.value];
}

@end
