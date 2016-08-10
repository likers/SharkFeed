//
//  HomeCollectionViewController.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/8/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeCollectionViewController.h"


@implementation HomeCollectionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationBar];
}

- (void)initNavigationBar {
    UIImageView *navImageBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavbarBackground"]];
    navImageBackground.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:navImageBackground];
    
    [navImageBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    
    UIImageView *logoString = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SharkFeedString"]];
    logoString.contentMode = UIViewContentModeScaleAspectFit;
    [navImageBackground addSubview:logoString];
    
    [logoString mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(navImageBackground);
        make.width.mas_equalTo(259);
        make.height.mas_equalTo(22);
    }];
}

- (void)initCollectionView {
    
}


@end