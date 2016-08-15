//
//  JLApi.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//


typedef void(^Complete)(NSData *, NSInteger);

@interface JLApi : NSObject

- (void)searchSharkForPage:(NSInteger)page completion:(Complete) compBlock;

- (void)searchWithText:(NSString *)text Page:(NSInteger)page completion:(Complete)compBlock;

- (void)getPhotoDetail:(NSString *)photoid completion:(Complete) compBlock;

- (void)downloadImage:(NSString *)imageurl completion:(Complete) compBlock;

@end
