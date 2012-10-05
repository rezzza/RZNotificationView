//
//  AutomaticModalViewController.m
//  RZNotificationView
//
//  Created by Marian Paul on 05/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "AutomaticModalViewController.h"

@interface AutomaticModalViewController ()

@end

@implementation AutomaticModalViewController

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
        self.title = @"Auto modal";
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1];
    }
    else
        self.title = [NSString stringWithFormat:@"Modal Level %d", self.navigationController.viewControllers.count+1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissModalViewControllerAnimated:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushController:(id)sender
{
    AutomaticModalViewController *m = [[AutomaticModalViewController alloc] initWithNibName:@"AutomaticModalViewController" bundle:nil];
    [self.navigationController pushViewController:m animated:YES];
}
@end
