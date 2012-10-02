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
    self.title = @"RZNotificationView Sample";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1];
    _notifView = [[RZNotificationView alloc] initWithMessage:@"No Message"];
    _notifView.delay = 3.5;
    _notifView.delegate = self;
    [_notifView setActionToCall:@selector(clicNotificationView:) withParam:@"rz://otherview"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button clic

- (void) clicNotificationView:(id)param
{
    if([param isKindOfClass:[NSString class]]){
        
    }
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
    _notifView.delay = _delaySlider.value;
}

- (IBAction) colorSelector:(NSIndexPath*)indexPath index:(NSInteger)index
{
    NSLog(@"%@", indexPath);
    NSLog(@"%d", index);
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
    PrettyGridTableViewCell *cell = (PrettyGridTableViewCell*) [self.tableView cellForRowAtIndexPath:_indexPath];
    if (_current == 0) {
        cell.gradientStartColor = [GzColors colorFromHex:hexColor];
        if(!cell.gradientEndColor)
            cell.gradientEndColor = [GzColors colorFromHex:hexColor];
        _notifView.customTopColor = [GzColors colorFromHex:hexColor];
    }
    else if (_current == 1) {
        if(!cell.gradientStartColor)
            cell.gradientStartColor = [GzColors colorFromHex:hexColor];
        cell.gradientEndColor = [GzColors colorFromHex:hexColor];
        _notifView.customBottomColor = [GzColors colorFromHex:hexColor];
    }
    [cell deselectAnimated:YES];
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (void) switchChange:(UISwitch*)sender
{
    _notifView.vibrate = sender.on;
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
    return 10;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
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
    
    PrettyCustomViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.tableViewBackgroundColor = tableView.backgroundColor;
    }
    
    // Configure the cell...
    [cell prepareForTableView:tableView indexPath:indexPath];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    
    switch (indexPath.row) {
        case 0:
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
        case 1:
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
        case 2:
            colorCell = [tableView dequeueReusableCellWithIdentifier:ColorCellIdentifier];
            if (colorCell == nil) {
                colorCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ColorCellIdentifier];
                
                UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 2.0, 260.0, 20.0)];
                positionLabel.text = [NSString stringWithFormat:@"Or predefined colors :"];
                positionLabel.numberOfLines = 1;
                positionLabel.textAlignment = UITextAlignmentCenter;
                positionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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
        case 3:
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
            
        case 4:
            iconCell = [tableView dequeueReusableCellWithIdentifier:IconCellIdentifier];
            if (iconCell == nil) {
                iconCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IconCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  [UIImage imageNamed:@"notif_facebook.png"],
                                  [UIImage imageNamed:@"notif_gift.png"],
                                  [UIImage imageNamed:@"notif_infos.png"],
                                  [UIImage imageNamed:@"notif_smiley.png"],
                                  [UIImage imageNamed:@"notif_twitter.png"],
                                  [UIImage imageNamed:@"notif_warning.png"],
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
        
        case 5:
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
        case 6:
            cell.textLabel.text = @"Hidde/Show Navbar";
            return cell;
        case 7:
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
        case 8:
            textStyleCell = [tableView dequeueReusableCellWithIdentifier:TextStyleCellIdentifier];
            if (textStyleCell == nil) {
                textStyleCell = [[PrettyCustomViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextStyleCellIdentifier];
                
                NSArray *items = [NSArray arrayWithObjects:
                                  @"Manual",
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
                
                segmentedControl.selectedSegmentIndex = 0;
                
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
        case 9:
            cell.textLabel.text = @"Show notification";
            return cell;
        
        default:
            break;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.row) {
        case 6:
            [self navBarHidden:nil];
            break;
        case 9:
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
            _notifView.message = [round objectAtIndex:_roundIndex%[round count]];
            [_notifView showFromController:self];
        }
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
            _notifView.color = sender.selectedSegmentIndex;
            _notifView.customBottomColor = nil;
            _notifView.customTopColor = nil;
            PrettyGridTableViewCell *cell = (PrettyGridTableViewCell*) [self.tableView cellForRowAtIndexPath:_indexPath];
            cell.gradientEndColor = nil;
            cell.gradientStartColor = nil;
            if(_indexPath)
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case 3:
            _notifView.position = sender.selectedSegmentIndex;
            break;
        case 4:
            _notifView.icon = sender.selectedSegmentIndex;
            break;
        case 7:
            [_notifView close];
            _sampleMessage = sender.selectedSegmentIndex;
            break;
        case 8:
            [_notifView close];
            _notifView.assetColor = sender.selectedSegmentIndex;
            break;
    }
}


@end
