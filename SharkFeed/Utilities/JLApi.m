//
//  JLApi.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLApi.h"

NSString *const APIKey = @"949e98778755d1982f537d56236bbb42";

@implementation JLApi

/**
 *  Searh api, but fix the search word to "shark"
 *
 *  @param page      page
 *  @param compBlock completion block
 */
- (void)searchSharkForPage:(NSInteger)page completion:(Complete)compBlock {
    NSString *searchText = @"shark";
    [self searchWithText:searchText Page:page completion:^(NSData *data, NSInteger code) {
        compBlock(data, code);
    }];
}

/**
 *  Flickr photo search API
 *
 *  @param text      search key word
 *  @param page      page
 *  @param compBlock completion block
 */
- (void)searchWithText:(NSString *)text Page:(NSInteger)page completion:(Complete)compBlock {
    NSString *searchUrl =[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&format=json&nojsoncallback=1&page=%ld&extras=url_t,url_c,url_l,url_o", APIKey, text, (long)page];
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

/**
 *  Flickr photo detail API
 *
 *  @param photoid   photo id
 *  @param compBlock completion block
 */
- (void)getPhotoDetail:(NSString *)photoid completion:(Complete) compBlock {
    NSString *detailUrl =[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", APIKey, photoid];
    NSURL *url = [NSURL URLWithString:detailUrl];
    
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

/**
 *  Image downloader
 *
 *  @param imageurl  url string
 *  @param compBlock completion block
 */
- (void)downloadImage:(NSString *)imageurl completion:(Complete) compBlock {
    NSURL *url = [NSURL URLWithString:imageurl];
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