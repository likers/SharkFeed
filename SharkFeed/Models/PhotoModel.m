//
//  PhotoModel.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoModel.h"


@implementation PhotoModel

@synthesize photoId, photoOwner, secret, server, farm, title;
@synthesize isPublic, isFriend, isFamily;
@synthesize urlTiny, heightTiny, widthTiny;
@synthesize urlCommon, heightCommon, widthCommon;
@synthesize urlLarge, heightLarge, widthLarge;
@synthesize urlOrigion, heightOrigion, widthOrigion;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.photoId = @"";
        self.photoOwner = @"";
        self.secret = @"";
        self.server = @"";
        self.farm = 0;
        self.title = @"";
        
        self.isPublic = NO;
        self.isFriend = NO;
        self.isFamily = NO;
        
        self.urlTiny = @"";
        self.heightTiny = 0;
        self.widthTiny = 0;
        
        self.urlCommon = @"";
        self.heightCommon = 0;
        self.widthCommon = 0;
        
        self.urlLarge = @"";
        self.heightLarge = 0;
        self.widthLarge = 0;
        
        self.urlOrigion = @"";
        self.heightOrigion = 0;
        self.widthOrigion = 0;
    }
    
    return self;
}

- (void)setPhotoModelWithDic:(NSDictionary *)dic {
    if (self) {
        self.photoId = [dic objectForKey:@"id"] == nil ? @"" : [dic objectForKey:@"id"];
        self.photoOwner = [dic objectForKey:@"owner"] == nil ? @"" : [dic objectForKey:@"owner"];
        self.secret = [dic objectForKey:@"secret"] == nil ? @"" : [dic objectForKey:@"secret"];
        self.server = [dic objectForKey:@"server"] == nil ? @"" : [dic objectForKey:@"server"];
        self.farm = [dic objectForKey:@"farm"] == nil ? 0 : [[dic objectForKey:@"farm"] integerValue];
        self.title = [dic objectForKey:@"title"] == nil ? @"" : [dic objectForKey:@"title"];
        
        self.isPublic = [dic objectForKey:@"ispublic"] == nil ? NO : [[dic objectForKey:@"ispublic"] boolValue];
        self.isFriend = [dic objectForKey:@"isfriend"] == nil ? NO : [[dic objectForKey:@"isfriend"] boolValue];
        self.isFamily = [dic objectForKey:@"isfamily"] == nil ? NO : [[dic objectForKey:@"isfamily"] boolValue];
        
        self.urlTiny = [dic objectForKey:@"url_t"] == nil ? @"" : [dic objectForKey:@"url_t"];
        self.heightTiny = [dic objectForKey:@"height_t"] == nil ? 0 : [[dic objectForKey:@"height_t"] integerValue];
        self.widthTiny = [dic objectForKey:@"width_t"] == nil ? 0 : [[dic objectForKey:@"width_t"] integerValue];
        
        self.urlCommon = [dic objectForKey:@"url_c"] == nil ? @"" : [dic objectForKey:@"url_c"];
        self.heightCommon = [dic objectForKey:@"height_c"] == nil ? 0 : [[dic objectForKey:@"height_c"] integerValue];
        self.widthCommon = [dic objectForKey:@"width_c"] == nil ? 0 : [[dic objectForKey:@"width_c"] integerValue];
        
        self.urlLarge = [dic objectForKey:@"url_l"] == nil ? @"" : [dic objectForKey:@"url_l"];
        self.heightLarge = [dic objectForKey:@"height_l"] == nil ? 0 : [[dic objectForKey:@"height_l"] integerValue];
        self.widthLarge = [dic objectForKey:@"width_l"] == nil ? 0 : [[dic objectForKey:@"width_l"] integerValue];
        
        self.urlOrigion = [dic objectForKey:@"url_o"] == nil ? @"" : [dic objectForKey:@"url_o"];
        self.heightOrigion = [dic objectForKey:@"height_o"] == nil ? 0 : [[dic objectForKey:@"height_o"] integerValue];
        self.widthOrigion = [dic objectForKey:@"width_o"] == nil ? 0 : [[dic objectForKey:@"width_o"] integerValue];
    }
}

@end