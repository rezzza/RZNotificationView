//
//  SampleViewController.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "SampleViewController.h"
#import "RZNotificationView.h"
#import "GzColors.h"

@interface SampleViewController ()

@end

@implementation SampleViewController

@synthesize popoverController;

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
    notifView.delegate = self;
    if(_topColorView.tag == 10)
        notifView.customTopColor = _topColorView.backgroundColor;
    if(_bottomColorView.tag == 10)
        notifView.customBottomColor = _bottomColorView.backgroundColor;
    [notifView showFromController:self];
}

- (IBAction) testButtonBottom:(id)sender
{
    RZNotificationView *notifView = [[RZNotificationView alloc] initWithMessage:@"Le test BOTTOM"];
    notifView.icon = RZNotificationIconSmiley;
    notifView.delay = _delaySlider.value;
    notifView.position = RZNotificationPositionBottom;
    notifView.color = RZNotificationColorBlue;
    notifView.delegate = self;
    if(_topColorView.tag == 10)
        notifView.customTopColor = _topColorView.backgroundColor;
    if(_bottomColorView.tag == 10)
        notifView.customBottomColor = _bottomColorView.backgroundColor;
    [notifView showFromController:self];
}

- (void) notificationViewTouched:(RZNotificationView*)notificationView
{
    NSLog(@"%@", notificationView);
}

- (IBAction) navBarHidden:(id)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (IBAction) sliderValueChanged:(id)sender
{
    _delayLabel.text = [NSString stringWithFormat:@"delay : %.1f", _delaySlider.value];
}

- (IBAction) colorSelector:(UIButton*)sender
{
    _currentBtn = sender;
    if (!self.popoverController) {
        ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        self.popoverController.delegate = self;
        self.popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
        
        [self.popoverController presentPopoverFromRect:sender.frame
                                                inView:self.view
                              permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                              animated:YES];
        
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor{
    if (_currentBtn.tag == 1) {
        _topColorView.backgroundColor = [GzColors colorFromHex:hexColor];
        _bottomColorView.tag = 10;
    }
    else if (_currentBtn.tag == 2) {
        _bottomColorView.backgroundColor = [GzColors colorFromHex:hexColor];
        _bottomColorView.tag = 10;
    }
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

@end
