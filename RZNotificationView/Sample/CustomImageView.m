//
//  CustomImageView.m
//  RZNotificationView
//
//  Created by Jérémy Lagrue on 02/10/12.
//  Copyright (c) 2012 Rezzza. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView

- (CGFloat) resizeForWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    
    CGFloat expectedHeight = self.frame.size.height*width/self.frame.size.width;
    if(80.0 < expectedHeight){
        frame.size.width = self.frame.size.width*40.0/self.frame.size.height;
        frame.size.height = 80.0;
        self.frame = frame;
        return self.frame.size.height;
    }
    
    frame.size.width = width;
    frame.size.height = self.frame.size.height*width/self.frame.size.width;
    self.frame = frame;
    return self.frame.size.height;
}

@end
