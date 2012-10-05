//
//  SimpleSampleViewController.m
//  RZNotificationView
//
//  Created by Marian Paul on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "SimpleSampleViewController.h"

#import "ModalViewController.h"

#import "RZNotificationView.h"

@interface SimpleSampleViewController ()

@end

@implementation SimpleSampleViewController

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
    
    self.title = @"Simple Demo";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showTwitter:(id)sender
{
    [RZNotificationView showNotificationOnTopMostControllerWithMessage:@"This is a twitter message!"
                                                                  icon:RZNotificationIconTwitter
                                                              position:RZNotificationPositionTop
                                                                 color:RZNotificationColorYellow
                                                            assetColor:RZNotificationAssetColorAutomaticLight
                                                             textColor:RZNotificationTextColorAutomaticDark
                                                                 withCompletion:nil];
}

- (IBAction)showWarning:(id)sender
{
    RZNotificationView *notif = [RZNotificationView showNotificationWithMessage:@"Warning, you did something wrong."
                                                                           icon:RZNotificationIconWarning
                                                                       position:RZNotificationPositionTop
                                                                          color:RZNotificationColorRed
                                                                     assetColor:RZNotificationAssetColorAutomaticDark
                                                                      textColor:RZNotificationTextColorAutomaticLight
                                                              addedToController:self
                                                                 withCompletion:nil];
    [notif setSound:@"DoorBell-SoundBible.com-1986366504.wav"];
    [notif setVibrate:YES];
}

- (IBAction)showFacebook:(id)sender
{
    [RZNotificationView showNotificationWithMessage:@"Tell your friends that RZNotificationView is awesome."
                                               icon:RZNotificationIconFacebook
                                           position:RZNotificationPositionBottom
                                              color:RZNotificationColorBlue
                                         assetColor:RZNotificationAssetColorAutomaticDark
                                          textColor:RZNotificationTextColorAutomaticLight
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
}

- (IBAction)hideAllNotifications:(id)sender
{
    [RZNotificationView hideAllNotificationsForController:self];
}

- (IBAction)presentModalView:(id)sender
{
    ModalViewController *modal = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:modal];
    [self presentModalViewController:nav animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
