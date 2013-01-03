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
#import "PrettyKit.h"
#import "MCSegmentedControl.h"
#import "CustomLabel.h"
#import "CustomImageView.h"
#import "MOOMaskedIconView.h"

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
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"KitchenSink";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1];
    
    _assetColor = RZNotificationContentColorAutomaticLight; // == 1
    _textColor = RZNotificationContentColorAutomaticLight; // == 1
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button clic

- (void) clicNotificationView:(RZNotificationView*)sender
{
    
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
    _delayLabel.text = [NSString stringWithFormat:@"Delay : %.1f", _delaySlider.value];
}

- (IBAction) colorSelector:(NSIndexPath*)indexPath index:(NSInteger)index
{
    _indexPath = indexPath;
    _current = index;
    if (!self.popoverController) {
        ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        self.popoverController.delegate = self;
        self.popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
        [self.popoverController presentPopoverFromRect:[self.tableView rectForRowAtIndexPath:indexPath]
                                                inView:self.view
                              permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                              animated:YES];
        
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor{
    // TODO
    PrettyGridTableViewCell *cell = (PrettyGridTableViewCell*) [self.tableView cellForRowAtIndexPath:_indexPath];
    if (_current == 0) {
        cell.gradientStartColor = [GzColors colorFromHex:hexColor];
        _customTopColor = [GzColors colorFromHex:hexColor];
        if(!cell.gradientEndColor)
            cell.gradientEndColor = [GzColors colorFromHex:hexColor];
    }
    else if (_current == 1) {
        if(!cell.gradientStartColor)
            cell.gradientStartColor = [GzColors colorFromHex:hexColor];
        cell.gradientEndColor = [GzColors colorFromHex:hexColor];
        _customBottomColor = [GzColors colorFromHex:hexColor];
    }
    [cell deselectAnimated:YES];
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (void) switchChange:(UISwitch*)sender
{
    _vibrate = sender.on;
}

- (void) switchChangeSound:(UISwitch*)sender
{
    if (sender.on){
        _sound = @"DoorBell-SoundBible.com-1986366504.wav";
    }
    else{
        _sound = nil;
    }
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
    PrettyGridTableViewCell *cell = (PrettyGridTableViewCell*) [self.tableView cellForRowAtIndexPath:_indexPath];
    [cell deselectAnimated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return 13;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return tableView.rowHeight + [PrettyTableViewCell
                                      tableView:tableView neededHeightForIndexPath:indexPath] + 20.0;
    }
    return tableView.rowHeight + [PrettyTableViewCell
                                  tableView:tableView neededHeightForIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    static NSString *DelayCellIdentifier = @"DelayCell";
    PrettyCustomViewTableViewCell *delayCell;
    
    static NSString *BgCellIdentifier = @"BgCell";
    PrettyGridTableViewCell *bgCell;

    static NSString *ColorCellIdentifier = @"ColorCellIdentifier";
    PrettyCustomViewTableViewCell *colorCell;
    
    static NSString *PositionCellIdentifier = @"PositionCellIdentifier";
    PrettyCustomViewTableViewCell *positionCell;
    
    static NSString *IconCellIdentifier = @"IconCellIdentifier";
    PrettyCustomViewTableViewCell *iconCell;
    
    static NSString *VibrateCellIdentifier = @"VibrateCellIdentifier";
    PrettyCustomViewTableViewCell *vibrateCell;
    
    static NSString *TextSampleCellIdentifier = @"TextSampleCellIdentifier";
    PrettyCustomViewTableViewCell *textSampleCell;
    
    static NSString *TextStyleCellIdentifier = @"TextStyleCellIdentifier";
    PrettyCustomViewTableViewCell *textStyleCell;
    
    static NSString *ContentStyleCellIdentifier = @"ContentStyleCellIdentifier";
    PrettyCustomViewTableViewCell *contentStyleCell;
    
    static NSString *SoundCellIdentifier = @"SoundCellIdentifier";
    PrettyCustomViewTableViewCell *soundCell;
    
    PrettyCustomViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.tableViewBackgroundColor = tableView.backgroundColor;
    }
    
    // Configure the cell...
    [cell prepareForTableView:tableView indexPath:indexPath];
    if (RZSystemVersionGreaterOrEqualThan(6.0))
    {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        cell.textLabel.textAlignment = UITextAlignmentCenter;
#pragma clang diagnostic pop
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Show notification";
            return cell;
        case 1:
            delayCell = [tableView dequeueReusableCellWithIdentifier:DelayCellIdentifier];
            if (delayCell == nil) {
                delayCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DelayCellIdentifier];
                _delaySlider = [ [ UISlider alloc ] initWithFrame: CGRectMake(120.0, 0.0, 190.0, 44.0) ];
                _delaySlider.minimumValue = 0.0;
                _delaySlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                _delaySlider.minimumTrackTintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                _delaySlider.maximumValue = 5.0;
                _delaySlider.value = 3.5;
                _delaySlider.continuous = YES;
                [_delaySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                
                _delayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 100.0, 44.0)];
                _delayLabel.text = [NSString stringWithFormat:@"Delay : %.1f", 3.5];
                _delayLabel.backgroundColor = [UIColor clearColor];
                _delayLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:_delaySlider];
                [delayView addSubview:_delayLabel];
                delayCell.customView = delayView;
            }
            [delayCell prepareForTableView:tableView indexPath:indexPath];
            delayCell.tableViewBackgroundColor = tableView.backgroundColor;
            return delayCell;
        case 2:
            bgCell = [tableView dequeueReusableCellWithIdentifier:BgCellIdentifier];
            if (bgCell == nil) {
                bgCell = [[PrettyGridTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BgCellIdentifier];
                bgCell.actionBlock = ^(NSIndexPath *indexPath, int selectedIndex) {
                    [self colorSelector:indexPath index:selectedIndex];
                };
            }
            [bgCell prepareForTableView:tableView indexPath:indexPath];
            bgCell.numberOfElements = 2;
            bgCell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
            [bgCell setText:@"Top Color" atIndex:0];
            [bgCell setText:@"Bottom Color" atIndex:1];

            return bgCell;
        case 3:
            colorCell = [tableView dequeueReusableCellWithIdentifier:ColorCellIdentifier];
            if (colorCell == nil) {
                colorCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ColorCellIdentifier];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 2.0, 260.0, 20.0)];
                positionLabel.text = [NSString stringWithFormat:@"Or predefined colors :"];
                positionLabel.numberOfLines = 1;
                if (RZSystemVersionGreaterOrEqualThan(6.0))
                {
                    positionLabel.textAlignment = NSTextAlignmentCenter;
                }
                else
                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    positionLabel.textAlignment = UITextAlignmentCenter;
#pragma clang diagnostic pop
                }                positionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Grey",
                                  @"Yellow",
                                  @"Red",
                                  @"Blue",
                                  nil];
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 2;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(20.0, 27.0, 280.0, 30.0);
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = 0;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44 + 15)];
                delayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                colorCell.customView = delayView;
            }
            [colorCell prepareForTableView:tableView indexPath:indexPath];
            colorCell.tableViewBackgroundColor = tableView.backgroundColor;
            return colorCell;
        case 4:
            positionCell = [tableView dequeueReusableCellWithIdentifier:PositionCellIdentifier];
            if (positionCell == nil) {
                positionCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PositionCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Top",
                                  @"Bottom",
                                  nil];
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 3;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(140.0, 7.0, 160.0, 30.0);
                [self.view addSubview:segmentedControl];
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = 0;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 100.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Position"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                positionCell.customView = delayView;
            }
            [positionCell prepareForTableView:tableView indexPath:indexPath];
            positionCell.tableViewBackgroundColor = tableView.backgroundColor;
            return positionCell;
            
        case 5:
            iconCell = [tableView dequeueReusableCellWithIdentifier:IconCellIdentifier];
            if (iconCell == nil) {
                iconCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IconCellIdentifier];
                
                MOOMaskedIconView *iconFacebook= [MOOMaskedIconView iconWithImage:[UIImage imageNamed:@"notif_facebook.png"]];
                MOOMaskedIconView *iconGift = [MOOMaskedIconView iconWithImage:[UIImage imageNamed:@"notif_gift.png"]];
                MOOMaskedIconView *iconInfo = [MOOMaskedIconView iconWithImage:[UIImage imageNamed:@"notif_infos.png"]];
                MOOMaskedIconView *iconSmiley = [MOOMaskedIconView iconWithImage:[UIImage imageNamed:@"notif_smiley.png"]];
                MOOMaskedIconView *iconTwitter = [MOOMaskedIconView iconWithImage:[UIImage imageNamed:@"notif_twitter.png"]];
                MOOMaskedIconView *iconWarning = [MOOMaskedIconView iconWithImage:[UIImage imageNamed:@"notif_warning.png"]];

                NSArray *items = [NSArray arrayWithObjects:
                                  [iconFacebook renderImage],
                                  [iconGift renderImage],
                                  [iconInfo renderImage],
                                  [iconSmiley renderImage],
                                  [iconTwitter renderImage],
                                  [iconWarning renderImage],
                                  @"No",
                                  nil];
                
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 4;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                
                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(90.0, 7.0, 210.0, 30.0);
                [self.view addSubview:segmentedControl];
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = 0;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 70.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Icon"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                iconCell.customView = delayView;
            }
            [iconCell prepareForTableView:tableView indexPath:indexPath];
            iconCell.tableViewBackgroundColor = tableView.backgroundColor;
            return iconCell;
        
        case 6:
            vibrateCell = [tableView dequeueReusableCellWithIdentifier:VibrateCellIdentifier];
            if (vibrateCell == nil) {
                vibrateCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VibrateCellIdentifier];
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.center = CGPointMake(220.0, 22.0);
                switchView.onTintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                switchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [switchView addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 70.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Vibrate"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:switchView];
                [delayView addSubview:positionLabel];
                vibrateCell.customView = delayView;
            }
            [vibrateCell prepareForTableView:tableView indexPath:indexPath];
            vibrateCell.tableViewBackgroundColor = tableView.backgroundColor;
            return vibrateCell;            
        case 7:
            cell.textLabel.text = @"Hidde/Show Navbar";
            return cell;
        case 8:
            textSampleCell = [tableView dequeueReusableCellWithIdentifier:TextSampleCellIdentifier];
            if (textSampleCell == nil) {
                textSampleCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextSampleCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Short",
                                  @"Medium",
                                  @"Long",
                                  nil];
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 7;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                
                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(140.0, 7.0, 175.0, 30.0);
                [self.view addSubview:segmentedControl];
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = 0;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 90.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Text Sample"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                textSampleCell.customView = delayView;
            }
            [textSampleCell prepareForTableView:tableView indexPath:indexPath];
            textSampleCell.tableViewBackgroundColor = tableView.backgroundColor;
            return textSampleCell;
        case 9:
            textStyleCell = [tableView dequeueReusableCellWithIdentifier:TextStyleCellIdentifier];
            if (textStyleCell == nil) {
                textStyleCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextStyleCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Light",
                                  @"Dark",
                                  nil];
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 8;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(140.0, 7.0, 175.0, 30.0);
                [self.view addSubview:segmentedControl];
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = _assetColor;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 90.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Asset Color"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                textStyleCell.customView = delayView;
            }
            [textStyleCell prepareForTableView:tableView indexPath:indexPath];
            textStyleCell.tableViewBackgroundColor = tableView.backgroundColor;
            return textStyleCell;
        case 10:
            textStyleCell = [tableView dequeueReusableCellWithIdentifier:TextStyleCellIdentifier];
            if (textStyleCell == nil) {
                textStyleCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextStyleCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Light",
                                  @"Dark",
                                  @"Manual",
                                  nil];
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 9;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(140.0, 7.0, 175.0, 30.0);
                [self.view addSubview:segmentedControl];
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = _textColor;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 90.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Text Color"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                textStyleCell.customView = delayView;
            }
            [textStyleCell prepareForTableView:tableView indexPath:indexPath];
            textStyleCell.tableViewBackgroundColor = tableView.backgroundColor;
            return textStyleCell;
        case 11:
            contentStyleCell = [tableView dequeueReusableCellWithIdentifier:ContentStyleCellIdentifier];
            if (contentStyleCell == nil) {
                contentStyleCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentStyleCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Label",
                                  @"Attributed",
                                  @"Image",
                                  nil];
                MCSegmentedControl *segmentedControl = [[MCSegmentedControl alloc] initWithItems:items];
                segmentedControl.tag = 10;
                segmentedControl.font = [UIFont boldSystemFontOfSize:14.0f];
                segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                
                // set frame, add to view, set target and action for value change as usual
                segmentedControl.frame = CGRectMake(100.0, 7.0, 215.0, 30.0);
                [self.view addSubview:segmentedControl];
                [segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
                
                segmentedControl.selectedSegmentIndex = 0;
                
                // Set a tint color
                segmentedControl.tintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                
                // Customize font and items color
                segmentedControl.selectedItemColor   = [UIColor whiteColor];
                segmentedControl.unselectedItemColor = [UIColor darkGrayColor];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 90.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Content"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:segmentedControl];
                [delayView addSubview:positionLabel];
                contentStyleCell.customView = delayView;
            }
            [contentStyleCell prepareForTableView:tableView indexPath:indexPath];
            contentStyleCell.tableViewBackgroundColor = tableView.backgroundColor;
            return contentStyleCell;
        case 12:
            soundCell = [tableView dequeueReusableCellWithIdentifier:SoundCellIdentifier];
            if (soundCell == nil) {
                soundCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SoundCellIdentifier];
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.center = CGPointMake(220.0, 22.0);
                switchView.onTintColor = [UIColor colorWithRed:.6 green:.0 blue:.0 alpha:1.0];
                switchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                [switchView addTarget:self action:@selector(switchChangeSound:) forControlEvents:UIControlEventValueChanged];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 70.0, 44.0)];
                positionLabel.text = [NSString stringWithFormat:@"Sound"];
                positionLabel.backgroundColor = [UIColor clearColor];
                positionLabel.font = [UIFont boldSystemFontOfSize:14.0];
                
                UIView *delayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 44)];
                [delayView addSubview:switchView];
                [delayView addSubview:positionLabel];
                soundCell.customView = delayView;
            }
            [soundCell prepareForTableView:tableView indexPath:indexPath];
            soundCell.tableViewBackgroundColor = tableView.backgroundColor;
            return soundCell;
        default:
            break;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.row) {
        case 0:
        {
            _roundIndex ++;
            NSArray *round ;
            switch (_sampleMessage) {
                case SampleMessageShort:
                {
                    round = [NSArray arrayWithObjects:
                             NSLocalizedString(@"Register now, for free", nil),
                             NSLocalizedString(@"Refer this app to a friend and earn money !", nil),
                             nil];
                }
                    break;
                case SampleMessageMedium:
                {
                    round = [NSArray arrayWithObjects:
                             NSLocalizedString(@"You just save 10 €, thank you for trusting us and see you soon! :)", nil),
                             NSLocalizedString(@"Thank you for your registration, please tap here to proceed further steps.", nil),
                             nil];
                }
                    break;
                case SampleMessageLong:
                {
                    round = [NSArray arrayWithObjects:
                             NSLocalizedString(@"Your friend \"John Appleseed\" just download the application ... Congratulations, you just won € 10 credit that can be used for your next purchase! :)", nil),
                             nil];
                }
                    break;
                default:
                    break;
            }
            
            // We don't want to stack the notifications, so hide before presenting a new one
            [RZNotificationView hideNotificationForController:self];
            
            RZNotificationView *notif =
            [[RZNotificationView alloc] initWithController:self
                                                      icon:_icon
                                                  position:_position
                                                     color:_color
                                                assetColor:_assetColor
                                                 textColor:_textColor
                                                     delay:_delaySlider.value
                                                completion:^(BOOL touched) {
                                                    if (touched) {
                                                        UIAlertView *alert =
                                                        [[UIAlertView alloc] initWithTitle:@"Message"
                                                                                   message:@"Anything you want"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"That's cool man"
                                                                         otherButtonTitles:nil];
                                                        [alert show];
                                                        // Add an URL to define custom action in you app
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"rzn://OtherViewController?the%20awesome%20message"]];
                                                    }
                                                }];
            
            [notif setMessage:[round objectAtIndex:_roundIndex%[round count]]];
            
            if (_textColor == RZNotificationContentColorManual) {
                notif.textLabel.textColor = [UIColor greenColor];
                notif.textLabel.shadowColor = [UIColor redColor];
            }
            
            [notif setVibrate:_vibrate];
            [notif setSound:_sound];
            [notif setAssetColor:_assetColor];
            [notif setTextColor:_textColor];
            [notif setCustomView:_customView];
            
            notif.customTopColor = _customTopColor;
            notif.customBottomColor = _customBottomColor;
            
            [notif show];

        }
            break;
        case 7:
            [self navBarHidden:nil];
            break;
        default:
            break;
    }
}

- (void)segmentedControlDidChange:(MCSegmentedControl *)sender
{
    switch (sender.tag) {
        case 2:
        {
            _color = sender.selectedSegmentIndex;
            PrettyGridTableViewCell *cell = (PrettyGridTableViewCell*) [self.tableView cellForRowAtIndexPath:_indexPath];
            cell.gradientEndColor = nil;
            cell.gradientStartColor = nil;
            _customBottomColor = nil;
            _customTopColor = nil;
            if(_indexPath)
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case 3:
            _position = sender.selectedSegmentIndex;
            break;
        case 4:
            _icon = sender.selectedSegmentIndex;
            break;
        case 7:
            [RZNotificationView hideNotificationForController:self];
            _sampleMessage = sender.selectedSegmentIndex;
            break;
        case 8:
            [RZNotificationView hideNotificationForController:self];
            _assetColor = sender.selectedSegmentIndex;
            break;
        case 9:
            [RZNotificationView hideNotificationForController:self];
            _textColor = sender.selectedSegmentIndex;
            break;
        case 10:
            [RZNotificationView hideNotificationForController:self];
            switch (sender.selectedSegmentIndex) {
                case 1:{
                    CustomLabel *customLabel = [[CustomLabel alloc] initWithFrame:CGRectZero];
                    customLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
                    customLabel.textColor = [UIColor darkGrayColor];
                    customLabel.numberOfLines = 0;
                    customLabel.backgroundColor = [UIColor clearColor];
                    customLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    customLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    if (RZSystemVersionGreaterOrEqualThan(6.0))
                    {
                        customLabel.textAlignment = NSTextAlignmentCenter;
                        customLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    }
                    else
                    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        customLabel.textAlignment = UITextAlignmentCenter;
                        customLabel.lineBreakMode = UILineBreakModeWordWrap;
#pragma clang diagnostic pop
                    }
                    customLabel.textColor = [UIColor blackColor];
                    customLabel.shadowColor = [UIColor whiteColor];
                    
                    NSString *text = @"Your friend \"John Appleseed\" just download the application ... Congratulations, you just won € 10 credit that can be used for your next purchase! :)";
                    [customLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"you just won € 10 credit" options:NSCaseInsensitiveSearch];
                        
                        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
                        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:12];
                        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
                        if (font) {
                            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
                            CFRelease(font);
                        }
                        
                        return mutableAttributedString;
                    }];
                    _customView = customLabel;
                }
                    break;
                case 2:{
                    CustomImageView *customImageView = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"340119_564053743608283_175259668_o.jpg"]];
                    customImageView.contentMode = UIViewContentModeScaleAspectFit;
                    _customView = customImageView;
                }
                    break;
                default:
                    _customView = nil;
                    break;
            }
            break;
    }
}


@end
