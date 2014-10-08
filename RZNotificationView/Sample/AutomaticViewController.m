//
//  AutomaticViewController.m
//  RZNotificationView
//
//  Created by Marian Paul on 05/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "AutomaticViewController.h"
#import "AutomaticModalViewController.h"

@interface AutomaticViewController ()

@end

@implementation AutomaticViewController

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
    if (self.navigationController.viewControllers.count == 1) {
        self.title = @"Auto Demo";
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1];
    }
    else
        self.title = [NSString stringWithFormat:@"Level %d", self.navigationController.viewControllers.count+1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushViewController:(id)sender
{
    AutomaticViewController *a = [[AutomaticViewController alloc] initWithNibName:@"AutomaticViewController" bundle:nil];
    [self.navigationController pushViewController:a animated:YES];
}
- (IBAction)presentModalController:(id)sender
{
    AutomaticModalViewController *m = [[AutomaticModalViewController alloc] initWithNibName:@"AutomaticModalViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:m];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"AutomaticViewController dealloc");
}

@end
