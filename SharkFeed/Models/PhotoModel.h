//
//  PhotoModel.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//

typedef NS_ENUM(NSUInteger, ImageStatus) {
    Empty,
    Downloading,
    Ready,
    Failed
};

@interface PhotoModel : NSObject

@property (nonatomic, copy) NSString *photoId;
@property (nonatomic, copy) NSString *photoOwner;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *server;
@property (nonatomic, assign) NSInteger farm;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) BOOL isFriend;
@property (nonatomic, assign) BOOL isFamily;

@property (nonatomic, copy) NSString *urlTiny;
@property (nonatomic, assign) NSInteger heightTiny;
@property (nonatomic, assign) NSInteger widthTiny;

@property (nonatomic, copy) NSString *urlCommon;
@property (nonatomic, assign) NSInteger heightCommon;
@property (nonatomic, assign) NSInteger widthCommon;

@property (nonatomic, copy) NSString *urlLarge;
@property (nonatomic, assign) NSInteger heightLarge;
@property (nonatomic, assign) NSInteger widthLarge;

@property (nonatomic, copy) NSString *urlOrigin;
@property (nonatomic, assign) NSInteger heightOrigin;
@property (nonatomic, assign) NSInteger widthOrigin;

@property (nonatomic, strong) NSData *currentImageData;
@property (nonatomic, assign) ImageStatus currentImageStatus;

- (void)setPhotoModelWithDic:(NSDictionary *)dic;

@end