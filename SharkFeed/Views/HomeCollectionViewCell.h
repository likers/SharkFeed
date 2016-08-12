//
//  HomeCollectionViewCell.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/10/16.
//  Copyright © 2016 likers33. All rights reserved.
//


#import "PhotoModel.h"

@interface HomeCollectionViewCell : UICollectionViewCell {
//    UIImageView *imageView;
}

@property (nonatomic, strong) PhotoModel *photo;
@property (nonatomic, strong) UIImageView *imageView;

@end