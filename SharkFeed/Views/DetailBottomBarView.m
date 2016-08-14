//
//  DetailBottomBarView.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/14/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailBottomBarView.h"
#import "UIButton+Extensions.h"


@implementation DetailBottomBarView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self initBackgroundView];
        [self initActionButtons];
        [self initDescription];
    }
    return self;
}

- (void)initBackgroundView {
    bottomBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottombarBackground"]];
    bottomBackgroundView.contentMode = UIViewContentModeScaleToFill;
    bottomBackgroundView.userInteractionEnabled = YES;
    [self addSubview:bottomBackgroundView];
    [bottomBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@206);
    }];
}

- (void)initActionButtons {
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectZero];
    downloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage imageNamed:@"DownloadIcon"] forState:UIControlStateNormal];
    [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    [downloadButton setImageEdgeInsets:UIEdgeInsetsMake(0, 29, 0, 0)];
    [downloadButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 30+18, 0, -86)];
    [downloadButton setHitTestEdgeInsets:UIEdgeInsetsMake(0, 0, -20, -86)];
    downloadButton.backgroundColor = [UIColor clearColor];
    downloadButton.titleLabel.textColor = [UIColor whiteColor];
    downloadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [bottomBackgroundView addSubview:downloadButton];
    [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(bottomBackgroundView);
        make.height.equalTo(@70);
        make.width.equalTo(@(bottomBackgroundView.frame.size.width/2));
    }];
    
    UIButton *flickrButton = [[UIButton alloc] initWithFrame:CGRectZero];
    flickrButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [flickrButton addTarget:self action:@selector(flickrAction) forControlEvents:UIControlEventTouchUpInside];
    [flickrButton setImage:[UIImage imageNamed:@"OpenInFlickr"] forState:UIControlStateNormal];
    [flickrButton setTitle:@"Open in App" forState:UIControlStateNormal];
    [flickrButton setImageEdgeInsets:UIEdgeInsetsMake(3, -86-18, 0, 0)];
    [flickrButton setTitleEdgeInsets:UIEdgeInsetsMake(3, -86, 0, 29)];
    [flickrButton setHitTestEdgeInsets:UIEdgeInsetsMake(0, -86, -20, 0)];
    flickrButton.backgroundColor = [UIColor clearColor];
    flickrButton.titleLabel.textColor = [UIColor whiteColor];
    flickrButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [bottomBackgroundView addSubview:flickrButton];
    [flickrButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(bottomBackgroundView);
        make.height.equalTo(@70);
        make.width.equalTo(@(bottomBackgroundView.frame.size.width/2));
    }];

    UIView *seperator = [[UIView alloc] initWithFrame:CGRectZero];
    seperator.backgroundColor = [UIColor whiteColor];
    [bottomBackgroundView addSubview:seperator];
    [seperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomBackgroundView).offset(23.5);
        make.right.equalTo(bottomBackgroundView).offset(-23.5);
        make.bottom.equalTo(bottomBackgroundView).offset(-70);
        make.height.equalTo(@1);
    }];
}

- (void)initDescription {
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    descriptionLabel.text = @"";
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont systemFontOfSize:16];
    [bottomBackgroundView addSubview:descriptionLabel];
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomBackgroundView).offset(-83);
        make.left.equalTo(bottomBackgroundView).offset(23);
        make.right.equalTo(bottomBackgroundView).offset(-23);
    }];
}

- (void)downloadAction {
    [delegate didClickDownload];
}

- (void)flickrAction {
    [delegate didClickOpenInFlickr];
}

- (void)updateDescription:(NSString *)text {
    [descriptionLabel setText:text];
    descriptionLabel.numberOfLines = 5;
    [descriptionLabel sizeToFit];
}


@end