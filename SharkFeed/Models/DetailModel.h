//
//  DetailModel.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/13/16.
//  Copyright © 2016 likers33. All rights reserved.
//



@interface DetailModel : NSObject

@property (nonatomic, copy) NSString *photoId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *photoTitle;
@property (nonatomic, copy) NSString *photoDescription;
@property (nonatomic, copy) UIImage *highResImage;
@property (nonatomic, copy) NSString *userIconUrl;

- (void)setDetailModelWithDic:(NSDictionary *)dic;

@end
