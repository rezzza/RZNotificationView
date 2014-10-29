//
//  SampleViewController.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 25/09/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZNotificationView.h"
#import <QuartzCore/QuartzCore.h>
#import "WEPopoverController.h"
#import "ColorViewController.h"

typedef NS_ENUM(NSInteger, SampleMessage) {
    SampleMessageShort = 0,
    SampleMessageMedium,
    SampleMessageLong
};

typedef NS_ENUM(NSInteger, RZSampleFormType)
{
    RZSampleFormShowButton,
    RZSampleFormDelay,
    RZSampleFormTopBotColors,
    RZSampleFormPredefinedColors,
    RZSampleFormPosition,
    RZSampleFormVibrate,
    RZSampleFormHideShowNavBar,
    RZSampleFormTextSample,
    RZSampleFormAssetColor,
    RZSampleFormTextColor,
    RZSampleFormContent,
    RZSampleFormSound,
    RZSampleFormAnchor,
    RZSampleFormMargin,
    RZSampleFormMaxLength,
    RZSampleFormIcon,
    RZSampleFormContext
};

@class PrettyGridTableViewCell;

@interface SampleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate>
{
    UISlider *_delaySlider;
    UILabel *_delayLabel;
    
    IBOutlet UITableView *_tableView;
    NSArray *_formArray;
    
    NSInteger _current;
    NSIndexPath *_indexPath;
    SampleMessage _sampleMessage;
    NSInteger _roundIndex;
    CGFloat _marginHeight;
    
    BOOL _vibrate;
    NSString *_sound;
    
    UIColor *_customTopColor, *_customBottomColor;
    
    RZNotificationColor _color;
    RZNotificationPosition _position;
    RZNotificationIcon _icon;
    RZNotificationAnchor _anchor;
    RZNotificationContext _context;
    
    RZNotificationContentColor _assetColor;
    RZNotificationContentColor _textColor;
    
    id<RZNotificationLabelProtocol> _customView;
    
    UISlider *_marginHeigtSlider;
    UILabel *_marginHeigtLabel;
    
    UISlider *_maxLenghtSlider;
    UILabel *_maxLenghtLabel;
}

@property (nonatomic, strong) WEPopoverController *popoverController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction) navBarHidden:(id)sender;
- (IBAction) sliderValueChanged:(id)sender;
- (void) switchChange:(UISwitch*)sender;

@end
