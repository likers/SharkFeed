//
//  HomeCollectionViewController.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/8/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "JLApi.h"
#import "PhotoModel.h"

@interface HomeCollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource> {
    CGFloat viewMargin;
}

@property (nonatomic, strong) UICollectionView *photoCollection;
@property (nonatomic, strong) NSMutableArray *photoArray;

@end