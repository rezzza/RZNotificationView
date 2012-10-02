//
//  RZNotificationLabel.h
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 02/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RZNotificationLabelProtocol <NSObject>

- (CGFloat) resizeForWidth:(CGFloat)width;
- (CGRect) frame;
- (void) setFrame:(CGRect)frame;
- (void) removeFromSuperview;

@end
