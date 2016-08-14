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
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    hookImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    hookImageView.image = [UIImage imageNamed:@"Hook"];
    hookImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:hookImageView];
    [hookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@31);
        make.left.right.top.equalTo(self);
    }];
    
    fishImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    fishImageView.image = [UIImage imageNamed:@"Fish"];
    fishImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:fishImageView];
    [fishImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.left.right.equalTo(self);
        make.top.equalTo(hookImageView.mas_bottom).offset(6);
    }];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Pull to refresh sharks";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor SFDarkText];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(100);
    }];
}

@end