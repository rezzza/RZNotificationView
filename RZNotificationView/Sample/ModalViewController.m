//
//  ModalViewController.m
//  RZNotificationView
//
//  Created by Marian Paul on 05/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "ModalViewController.h"
#import "RZNotificationView.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissModalViewControllerAnimated:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showNotif:(id)sender {
    
    [RZNotificationView showNotificationOnTopMostControllerWithMessage:@"This is a notification shown without setting a specific view controller. This could be called from anywhere."
                                                                  icon:RZNotificationIconTwitter
                                                              position:RZNotificationPositionTop
                                                                 color:RZNotificationColorYellow
                                                            assetColor:RZNotificationAssetColorAutomaticLight
                                                             textColor:RZNotificationTextColorAutomaticDark
                                                                 delay:3.5];
    
    
}
@end
