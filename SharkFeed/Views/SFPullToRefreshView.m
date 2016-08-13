//
//  SFPullToRefreshView.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/13/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPullToRefreshView.h"


@implementation SFPullToRefreshView

@synthesize state;

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SFPullToRefreshStateStopped;
        
        titles = [NSMutableArray arrayWithObjects:@"Pull to refresh sharks",
                       @"Release to refresh",
                       @"Loading...",
                       nil];
    }
    
    return self;
}

- (void)layoutSubviews {
    hookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 31)];
    hookImageView.image = [UIImage imageNamed:@"Hook"];
    hookImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:hookImageView];
    
    fishImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 31+6, self.frame.size.width, 44)];
    fishImageView.image = [UIImage imageNamed:@"Fish"];
    fishImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:fishImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.frame.size.width, 20)];
    titleLabel.text = @"Pull to refresh sharks";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor SFDarkText];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
}

@end