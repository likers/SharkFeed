//
//  ImageDownloadOperation.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/11/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDownloadOperation.h"

@interface ImageDownloadOperation ()

@property (nonatomic, weak) NSCache *mCache;

@end

@implementation ImageDownloadOperation

@synthesize mCache;


-(id)initWithUrl:(NSString *)url Cache:(NSCache *)cache {
    if (self = [super init]) {
        self.mCache = cache;
        imageUrl = url;
    }
    return self;
}

- (void)main {
    if (self.cancelled) {
        return;
    }
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (self.cancelled) {
        return;
    }
    if ([data length] > 0) {
        UIImage *image = [UIImage imageWithData:data];
        [self.mCache setObject:image forKey:imageUrl];
    }
}

@end