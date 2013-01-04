//
//  RZNotificationLabel.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 02/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 RZNotificationLabelProtocol protocol
 Your custom view must be coform to this protocol
 */
@protocol RZNotificationLabelProtocol <NSObject>

/** Called when notification view is drawn
 @param width with max available for your custom view
 @return height you need for your custom view
 */
- (CGFloat) resizeForWidth:(CGFloat)width;

/** 
 @return cutomView frame
 */
- (CGRect) frame;

/**  set customView frame
 @param frame frame to use
 */
- (void) setFrame:(CGRect)frame;

/**  remove from superview
 */
- (void) removeFromSuperview;

@end
