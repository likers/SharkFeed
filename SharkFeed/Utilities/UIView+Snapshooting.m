//
//  UIView+Snapshooting.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/14/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Snapshooting.h"


@implementation UIView (Snapshotting)

-(UIImage *)takeSnapshot
{
    // Use pre iOS-7 snapshot API since we need to render views that are off-screen.
    // iOS 7 snapshot API allows us to snapshot only things on screen
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:ctx];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

@end