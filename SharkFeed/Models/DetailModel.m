//
//  DetailModel.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/13/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailModel.h"


@implementation DetailModel

@synthesize photoId, userName, photoTitle, photoDescription, highResImage, userIconUrl;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.photoId = @"";
        self.userName = @"";
        self.photoTitle = @"";
        self.photoDescription = @"";
        self.highResImage = nil;
        self.userIconUrl = @"";
    }
    
    return self;
}

- (void)setDetailModelWithDic:(NSDictionary *)dic {
    if (self) {
        self.photoId = [dic objectForKey:@"id"] == nil ? @"" : [dic objectForKey:@"id"];
        self.photoTitle = [dic objectForKey:@"title"] == nil ? @"" : [[dic objectForKey:@"title"] objectForKey:@"_content"];
        self.photoDescription = [dic objectForKey:@"description"] == nil ? @"" : [[dic objectForKey:@"description"] objectForKey:@"_content"];
        self.userName = [dic objectForKey:@"owner"] == nil ? @"" : [[dic objectForKey:@"owner"] objectForKey:@"username"];
        self.userIconUrl = [NSString stringWithFormat:@"https://farm%ld.staticflickr.com/%@/buddyicons/%@.jpg", [[[dic objectForKey:@"owner"] objectForKey:@"iconfarm"] integerValue], [[dic objectForKey:@"owner"] objectForKey:@"iconserver"], [[dic objectForKey:@"owner"] objectForKey:@"nsid"]];
    }
}

@end