//
//  JLApi.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLApi.h"

NSString *const Key = @"949e98778755d1982f537d56236bbb42";

@implementation JLApi

- (void)searchSharkForPage:(NSInteger)page completion:(Complete)compBlock {
    NSString *searchText = @"shark";
//    NSString *searchText = @"test";
    [self searchWithText:searchText Page:page completion:^(NSData *data, NSInteger code) {
        compBlock(data, code);
    }];
}

- (void)searchWithText:(NSString *)text Page:(NSInteger)page completion:(Complete)compBlock {
    NSString *searchUrl =[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&format=json&nojsoncallback=1&page=%ld&extras=url_t,url_c,url_l,url_o", Key, text, (long)page];
    NSURL *url = [NSURL URLWithString:searchUrl];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (httpResponse.statusCode == 200) {
            compBlock(data, httpResponse.statusCode);
        }
    }];
    
    [downloadTask resume];
}

@end