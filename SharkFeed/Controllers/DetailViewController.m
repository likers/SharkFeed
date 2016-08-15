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

#pragma mark - Getting Data
/**
 *  Fetch photo detail infomation from server
 */
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
                /**
                 *  Use title as description if it's empty
                 */
                [bottomBar updateDescription:[detail.photoDescription isEqualToString:@""] ? detail.photoTitle : detail.photoDescription];
                [self addIconAndUserName];
            });
        }
    }];
}

/**
 *  Download high resolution image via url
 */
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

#pragma mark - Initial views
- (void)initPhotoView {
    photoView = [[UIImageView alloc] initWithImage:self.lowResImage];
    photoView.frame = self.view.frame;
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addGestureRecognizerToView:photoView];
    [photoView setUserInteractionEnabled:YES];
    [photoView setMultipleTouchEnabled:YES];
    [self.view addSubview:photoView];
    
    /**
     *  Minimum frame for photo zoom out
     */
    minFrame = photoView.frame;
}

/**
 *  Initial top bar which shows username, avatar and close button
 */
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
    [self dismissViewControllerAnimated:YES completion:^{}];
}

/**
 *  Add icon and username when detail information is ready
 */
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

/**
 *  Add custom DetailBottomBarView to bottom
 */
- (void)initBottomBar {
    bottomBar = [[DetailBottomBarView alloc] initWithFrame:CGRectZero];
    bottomBar.delegate = self;
    [self.view addSubview:bottomBar];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.equalTo(@206);
    }];
}

#pragma mark - DetailBottomBarView delegates
- (void)didClickDownload {
    if (highResImage != nil) {
        UIImageWriteToSavedPhotosAlbum(highResImage, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    } else {
        UIImageWriteToSavedPhotosAlbum(lowResImage, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
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


#pragma mark - Custom transition delegate
- (UIView *)viewForTransition {
    return photoView;
}

- (CGRect)rectForViewToTrans {
    return photoView.frame;
}

- (UIImage *)imageToTrans {
    return photoView.image;
}

#pragma mark - Gesture related
/**
 *  Add Pinch, Pan, Tap gesture to photoView
 *
 *  @param view photoView
 */
- (void)addGestureRecognizerToView:(UIView *)view {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnImage:)];
    [view addGestureRecognizer:tap];
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        if (photoView.frame.size.width < minFrame.size.width) {
            photoView.frame = minFrame;
        }
        pinchGestureRecognizer.scale = 1;
    }
}

- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (photoView.frame.size.width > deviceWidth) {
            CGPoint translation = [panGestureRecognizer translationInView:view.superview];
            [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
}

- (void)tapOnImage:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        topBarBackground.alpha = infoHidden;
        bottomBar.alpha = infoHidden;
    } completion:^(BOOL finished) {
        infoHidden = !infoHidden;
    }];
}

@end