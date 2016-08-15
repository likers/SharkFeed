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

@interface HomeCollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate, TransitionProtocol, UINavigationControllerDelegate, UIViewControllerPreviewingDelegate> {
    
    CGFloat viewMargin;
    CGFloat cellSize;
    NSOperationQueue *downloadQueue;
    
    /**
     *  Dictionary that stores all downloading operations
     */
    NSMutableDictionary *pendingDownloadDic;
    
    /**
     *  Current page number(actually it's better to be nextPage) for api request
     */
    NSInteger currentPage;
    
    /**
     *  YES when fetching data from server
     */
    BOOL isLoadingMore;
    
    SFPullToRefreshView *refreshView;
    NSIndexPath *selectedIndex;
}

@property (nonatomic, strong) UICollectionView *photoCollection;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSCache *imageCache;

@end