//
//  SFPullToRefreshView.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/13/16.
//  Copyright © 2016 likers33. All rights reserved.
//

typedef NS_ENUM(NSUInteger, SFPullToRefreshState) {
    SFPullToRefreshStateStopped,
    SFPullToRefreshStateTriggered,
    SFPullToRefreshStateLoading
};

@interface SFPullToRefreshView : UIView {
    UILabel *titleLabel;
    UIImageView *hookImageView;
    UIImageView *fishImageView;
}

@property (nonatomic, assign) SFPullToRefreshState state;

- (void)startAnimating;
- (void)stopAnimating:(void(^)(void))complete;

@end
