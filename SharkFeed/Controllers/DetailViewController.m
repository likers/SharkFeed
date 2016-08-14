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
    photoView = [[UIImageView alloc] initWithImage:self.lowResImage];
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:photoView];
    [photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
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
    
}

@end