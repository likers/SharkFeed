//
//  HomeCollectionViewCell.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeCollectionViewCell.h"


@implementation HomeCollectionViewCell

@synthesize imageView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)initView {
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceHolder"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setPhoto:(PhotoModel *)photo {
    _photo = photo;
    
    [imageView setImage:[UIImage imageNamed:@"PlaceHolder"]];
    
    if (photo.currentImageData != nil) {
        imageView.alpha = 0.5;
        UIImage *toImage = [UIImage imageWithData:photo.currentImageData];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            imageView.image = toImage;
            imageView.alpha = 1;
        } completion:nil];
    }
    
//    [imageView setImage:[UIImage imageNamed:@"PlaceHolder"]];
    
//    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//    dispatch_async(backgroundQueue, ^(void) {
//        NSURL *url = [NSURL URLWithString:photo.urlCommon];
//        NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
//                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//        {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//            if (httpResponse.statusCode == 200) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [imageView setImage:[UIImage imageWithData:data]];
//                });
//            }
//        }];
//    
//        [downloadTask resume];
//    });
}

@end