//
//  DetailBottomBarView.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/14/16.
//  Copyright © 2016 likers33. All rights reserved.
//

@protocol DetailBottomBarViewDelegate <NSObject>

@optional
- (void)didClickDownload;
- (void)didClickOpenInFlickr;

@end

@interface DetailBottomBarView : UIView {
    UIImageView *bottomBackgroundView;
    UILabel *descriptionLabel;
}

@property (nonatomic, weak) id <DetailBottomBarViewDelegate> delegate;

- (void)updateDescription:(NSString *)text;

@end
