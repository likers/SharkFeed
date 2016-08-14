//
//  DetailViewController.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/13/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"
#import "JLApi.h"


@implementation DetailViewController

@synthesize photo, lowResImage;


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    highResImage = nil;
    infoHidden = NO;
    [self initPhotoView];
    [self initTopBar];
    [self initBottomBar];
    [self fetchDetail];
    [self downloadHighResImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)fetchDetail {
    JLApi *api = [[JLApi alloc] init];
    [api getPhotoDetail:photo.photoId completion:^(NSData *data, NSInteger statusCode) {
        if (statusCode == 200) {
            NSError* error;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
            detail = [[DetailModel alloc] init];
            [detail setDetailModelWithDic:[result objectForKey:@"photo"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [bottomBar updateDescription:[detail.photoDescription isEqualToString:@""] ? detail.photoTitle : detail.photoDescription];
                [self addIconAndUserName];
            });
        }
    }];
}

- (void)downloadHighResImage {
    JLApi *api = [[JLApi alloc] init];
    [api downloadImage:self.photo.urlOrigin completion:^(NSData *data, NSInteger statusCode) {
        if (statusCode == 200 && data != nil) {
            highResImage = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [photoView setImage:highResImage];
            });
        }
    }];
}

- (void)initPhotoView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage:)];
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//    [doubleTap setNumberOfTapsRequired:2];
    photoView = [[UIImageView alloc] initWithImage:self.lowResImage];
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    photoView.userInteractionEnabled = YES;
    [photoView addGestureRecognizer:tap];
    [self.view addSubview:photoView];
    [photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)tapOnImage:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        topBarBackground.alpha = infoHidden;
        bottomBar.alpha = infoHidden;
    } completion:^(BOOL finished) {
        infoHidden = !infoHidden;
    }];
}

- (void)initTopBar {
    topBarBackground = [[UIView alloc] initWithFrame:CGRectZero];
    topBarBackground.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topBarBackground];
    
    [topBarBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@44);
    }];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [closeButton setImage:[UIImage imageNamed:@"CloseIcon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [topBarBackground addSubview:closeButton];

    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBarBackground).offset(16);
        make.right.equalTo(topBarBackground).offset(-16);
        make.height.equalTo(@22);
        make.width.equalTo(@22);
    }];
}

- (void)addIconAndUserName {
    NSInteger hasIcon = 0;
    NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:detail.userIconUrl]];
    if (iconData != nil) {
        hasIcon = 1;
        iconView = [[UIImageView alloc] init];
        iconView.image = [UIImage imageWithData:iconData];
        iconView.layer.cornerRadius = 15;
        iconView.clipsToBounds = YES;
        [topBarBackground addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topBarBackground).offset(12);
            make.left.equalTo(topBarBackground).offset(16);
            make.bottom.equalTo(topBarBackground).offset(-2);
            make.width.equalTo(@30);
            make.height.equalTo(@30);
        }];
    }
    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    userNameLabel.text = detail.userName;
    userNameLabel.textColor = [UIColor whiteColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:16];
    [topBarBackground addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBarBackground).offset(16);
        make.left.equalTo(topBarBackground).offset(16+hasIcon*40);
        make.height.equalTo(@20);
    }];
    [userNameLabel sizeToFit];
}

- (void)backAction {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)initBottomBar {
    bottomBar = [[DetailBottomBarView alloc] initWithFrame:CGRectZero];
    bottomBar.delegate = self;
    [self.view addSubview:bottomBar];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@206);
    }];
}

- (void)didClickDownload {
    if (highResImage != nil) {
        UIImageWriteToSavedPhotosAlbum(highResImage, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    } else {
        UIImageWriteToSavedPhotosAlbum(highResImage, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)   savedPhotoImage:(UIImage *)image
  didFinishSavingWithError:(NSError *)error
               contextInfo:(void *)contextInfo
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success!" message:@"This image has been saved to your camera roll" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didClickOpenInFlickr {
    UIApplication *application = [UIApplication sharedApplication];
    NSString *url = [NSString stringWithFormat:@"flickr://photos/%@/%@", detail.userName, detail.photoId];
    [application openURL:[NSURL URLWithString:url]];
}

- (UIView *)viewForTransition {
    return photoView;
}

@end