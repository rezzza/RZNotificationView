//
//  SimpleSampleViewController.m
//  RZNotificationView
//
//  Created by Marian Paul on 04/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "SimpleSampleViewController.h"
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showTwitter:(id)sender
{
    [RZNotificationView showNotificationWithMessage:@"This is a twitter message!"
                                               icon:RZNotificationIconTwitter
                                           position:RZNotificationPositionTop
                                              color:RZNotificationColorYellow
                                         assetColor:RZNotificationAssetColorAutomaticLight
                                  addedToController:self];
}

- (IBAction)showWarning:(id)sender
{
    RZNotificationView *notif = [RZNotificationView showNotificationWithMessage:@"Warning, you did something wrong."
                                                                           icon:RZNotificationIconWarning
                                                                       position:RZNotificationPositionTop
                                                                          color:RZNotificationColorRed
                                                                     assetColor:RZNotificationAssetColorAutomaticLight
                                                              addedToController:self];
    [notif setSound:@"DoorBell-SoundBible.com-1986366504.wav"];
    [notif setVibrate:YES];
}

- (IBAction)showFacebook:(id)sender
{
    [[RZNotificationView showNotificationWithMessage:@"Tell your friends that RZNotificationView is awesome."
                                               icon:RZNotificationIconFacebook
                                           position:RZNotificationPositionBottom
                                              color:RZNotificationColorBlue
                                         assetColor:RZNotificationAssetColorAutomaticLight
                                  addedToController:self]
     setUrlToOpen:[NSURL URLWithString:@"fb://"]];
}
@end
