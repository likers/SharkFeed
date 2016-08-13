//
//  ImageDownloadOperation.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/11/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDownloadOperation.h"

@interface ImageDownloadOperation () {
    PhotoModel *mPhoto;
}

@property (nonatomic, strong) PhotoModel *mPhoto;

@end

@implementation ImageDownloadOperation

@synthesize mPhoto;

-(id)initWithPhoto:(PhotoModel *)photo {
    if (self = [super init]) {
        self.mPhoto = photo;
    }
    return self;
}

- (void)main {
    if (self.cancelled) {
        return;
    }
    NSURL *url = [self.mPhoto.urlCommon isEqualToString:@""] ? [NSURL URLWithString:self.mPhoto.urlOrigin] : [NSURL URLWithString:self.mPhoto.urlCommon];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (self.cancelled) {
        return;
    }
    if ([data length] > 0) {
        self.mPhoto.currentImageData = data;
        self.mPhoto.currentImageStatus = Ready;
    } else {
        self.mPhoto.currentImageData = nil;
        self.mPhoto.currentImageStatus = Failed;
    }
}

@end