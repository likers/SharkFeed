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
#import "SFPullToRefreshView.h"
#import "Transitionprotocol.h"

@interface HomeCollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate, TransitionProtocol, UINavigationControllerDelegate> {
    CGFloat viewMargin;
    CGFloat cellSize;
    NSOperationQueue *downloadQueue;
    NSMutableDictionary *pendingDownloadDic;
    NSInteger currentPage;
    BOOL isLoadingMore;
    SFPullToRefreshView *refreshView;
    NSIndexPath *selectedIndex;
}

@property (nonatomic, strong) UICollectionView *photoCollection;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSCache *imageCache;

@end