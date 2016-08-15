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

- (void)startAnimating {
    titleLabel.text = @"Feeding...";
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
    rotation.keyPath = @"transform.rotation";
    rotation.values = @[ @0, @0.2, @-0.2, @0];
    rotation.duration = 0.3;
    rotation.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
    rotation.repeatCount = HUGE_VAL;
    [fishImageView.layer addAnimation:rotation forKey:@"feeding"];
}

- (void)stopAnimating:(void(^)(void))complete {
    [fishImageView.layer removeAllAnimations];
    titleLabel.text = @"Gocha!";
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fishImageView.frame = CGRectMake(fishImageView.frame.origin.x, fishImageView.frame.origin.y-15, fishImageView.frame.size.width, fishImageView.frame.size.height);
    } completion:^(BOOL finished) {
        complete();
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fishImageView.frame = CGRectMake(fishImageView.frame.origin.x, fishImageView.frame.origin.y+15, fishImageView.frame.size.width, fishImageView.frame.size.height);
        } completion:^(BOOL finished) {
            titleLabel.text = @"Pull to refresh sharks";
        }];
    }];
}

@end