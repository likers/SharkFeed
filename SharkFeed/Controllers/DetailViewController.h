//
//  DetailViewController.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/13/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import "PhotoModel.h"
#import "DetailModel.h"
#import "DetailBottomBarView.h"
#import "TransitionProtocol.h"


@interface DetailViewController : UIViewController<DetailBottomBarViewDelegate, TransitionProtocol> {
    UIView *topBarBackground;
    DetailBottomBarView *bottomBar;
    DetailModel *detail;
    UIImageView *photoView;
    UIImage *highResImage;
    UILabel *userNameLabel;
    UILabel *geoLabel;
    UIImageView *iconView;
    BOOL infoHidden;
}

@property (nonatomic, strong) PhotoModel *photo;
@property (nonatomic, strong) UIImage *lowResImage;

@end