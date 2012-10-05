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
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1];

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
    
    [RZNotificationView showNotificationWithMessage:@"Yeah that works on a modal view too!"
                                               icon:RZNotificationIconTwitter
                                           position:RZNotificationPositionTop
                                              color:RZNotificationColorYellow
                                         assetColor:RZNotificationContentColorAutomaticLight
                                          textColor:RZNotificationContentColorAutomaticDark
                                  addedToController:self
                                     withCompletion:nil];
    
    
}
@end
