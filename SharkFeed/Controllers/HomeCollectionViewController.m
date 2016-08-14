//
//  HomeCollectionViewController.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/8/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeCollectionViewController.h"
#import "ImageDownloadOperation.h"
#import "DetailViewController.h"


static CGFloat const SFPullToRefreshViewHeight = 130;

@implementation HomeCollectionViewController

@synthesize photoCollection, photoArray, imageCache;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self initNavigationBar];
    [self initData];
}

- (void)initNavigationBar {
    UIImageView *navImageBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavbarBackground"]];
    navImageBackground.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:navImageBackground];
    
    [navImageBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(navBarHeight);
    }];
    
    UIImageView *logoString = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SharkFeedString"]];
    logoString.contentMode = UIViewContentModeScaleAspectFit;
    [navImageBackground addSubview:logoString];
    
    [logoString mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(navImageBackground);
        make.width.mas_equalTo(259);
        make.height.mas_equalTo(22);
    }];
}

- (void)initData {
    currentPage = 1;
    viewMargin = 21;
    cellSize = (deviceWidth - viewMargin*2 - 6*2)/3;
    isLoadingMore = NO;
    photoArray = [[NSMutableArray alloc] init];
    imageCache = [[NSCache alloc] init];
    pendingDownloadDic = [[NSMutableDictionary alloc] init];
    downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.maxConcurrentOperationCount = 5;
    
    [self getDataForPage:currentPage isRefresh:NO];
}

- (void)getDataForPage:(NSInteger) page isRefresh:(BOOL) isPullToRefresh{
    JLApi *api = [[JLApi alloc] init];
    [api searchSharkForPage:page completion:^(NSData *data, NSInteger statusCode) {
        if (statusCode == 200) {
            [self cancelAllDownloads];
            NSError* error;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
            NSLog(@"total1: %ld", [[[result objectForKey:@"photos"] objectForKey:@"total"] integerValue]);
            if (isPullToRefresh) {
                [photoArray removeAllObjects];
            }
            for (NSDictionary *dic in [[result objectForKey:@"photos"] objectForKey:@"photo"]) {
                PhotoModel *photo = [[PhotoModel alloc] init];
                [photo setPhotoModelWithDic:dic];
                [photoArray addObject:photo];
            }
            NSLog(@"total2: %lu", (unsigned long)[photoArray count]);
            
            if (page == 1) {
                if (!isPullToRefresh) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self initCollectionView];
                    });
                } else if (isPullToRefresh) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self resumeScrollViewUp:self.photoCollection completion:^{
                            [self.photoCollection reloadData];
                        }];
                    });
                }
            } else {
                isLoadingMore = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.photoCollection reloadData];
                });
            }
        }
    }];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 6;
    flowLayout.minimumLineSpacing = 6;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 21, 0, 21);
    
    photoCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    photoCollection.delegate = self;
    photoCollection.dataSource = self;
    photoCollection.backgroundColor = [UIColor whiteColor];
    [photoCollection registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:photoCollection];
    
    [photoCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(navBarHeight+viewMargin);
    }];
    
    refreshView = [[SFPullToRefreshView alloc] initWithFrame:CGRectMake(0, -SFPullToRefreshViewHeight, photoCollection.frame.size.width, SFPullToRefreshViewHeight)];
    [photoCollection addSubview:refreshView];
}

// MARK: collectionView datasource and delegation
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [photoArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoModel *photo = [photoArray objectAtIndex:indexPath.row];
    NSString *url = [photo.urlCommon isEqualToString:@""] ? photo.urlOrigin : photo.urlCommon;
    
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.imageView.image = nil;
    
    if ([self.imageCache objectForKey:url] != nil) {
        cell.imageView.image = [self.imageCache objectForKey:url];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"PlaceHolder"];
        [self downloadForUrl:url Index:indexPath];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    CGFloat cellSize = (deviceWidth - viewMargin*2 - 6*2)/3;
    return CGSizeMake(cellSize, cellSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoModel *photo = [photoArray objectAtIndex:indexPath.row];
    NSString *url = [photo.urlCommon isEqualToString:@""] ? photo.urlOrigin : photo.urlCommon;
    
    if ([imageCache objectForKey:url] != nil) {
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        detailVC.photo = photo;
        detailVC.lowResImage = [imageCache objectForKey:url];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!isLoadingMore && [photoArray count] - (indexPath.row+1) < 50) {
        currentPage += 1;
        isLoadingMore = YES;
        [self cancelAllDownloads];
        [self getDataForPage:currentPage isRefresh:NO];
    }
}

// MARK: imageDownloader
- (void)downloadForUrl:(NSString *)url Index:(NSIndexPath *)indexPath {
    if ([pendingDownloadDic objectForKey:indexPath] != nil) {
        return;
    } else {
        ImageDownloadOperation *downloader = [[ImageDownloadOperation alloc] initWithUrl:url Cache:self.imageCache];
        downloader.completionBlock = ^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [pendingDownloadDic removeObjectForKey:indexPath];
                [self.photoCollection reloadItemsAtIndexPaths:@[indexPath]];
            }];
        };
        [pendingDownloadDic setObject:downloader forKey:indexPath];
        [downloadQueue addOperation:downloader];
    }
}

// MARK: - ScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self cancelOffscreenCells];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY <= -60 && refreshView.state == SFPullToRefreshStateStopped) {
        [self pullScrollViewDown:scrollView completion:^{
            refreshView.state = SFPullToRefreshStateLoading;
            [self cancelAllDownloads];
            [self getDataForPage:1 isRefresh:YES];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self cancelOffscreenCells];
}

- (void)cancelOffscreenCells {
    NSArray *pathArray = [self.photoCollection indexPathsForVisibleItems];
    NSMutableArray *cancelArray = [[NSMutableArray alloc] init];
    [pendingDownloadDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![pathArray containsObject:key]) {
            [cancelArray addObject:key];
        }
    }];
    for (NSIndexPath *index in cancelArray) {
        NSLog(@"cancel row: %ld",(long)index.row);
        [[pendingDownloadDic objectForKey:index] cancel];
        [pendingDownloadDic removeObjectForKey:index];
    }
}

- (void)cancelAllDownloads {
    for (NSIndexPath *path in pendingDownloadDic) {
        [[pendingDownloadDic objectForKey:path] cancel];
    }
    [pendingDownloadDic removeAllObjects];
}

- (void)pullScrollViewDown:(UIScrollView *)scrollView completion:(void(^)(void))complete {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    refreshView.state = SFPullToRefreshStateTriggered;
    [scrollView setContentInset:UIEdgeInsetsMake(130, 0, 0, 0)];
    [UIView animateWithDuration:0.3 animations:^{
        [scrollView setContentOffset:CGPointMake(contentOffsetX, -130)];
    } completion:^(BOOL finished) {
        complete();
    }];
}

- (void)resumeScrollViewUp:(UIScrollView *)scrollView completion:(void(^)(void))complete {
    refreshView.state = SFPullToRefreshStateStopped;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat contentOffsetX = self.photoCollection.contentOffset.x;
        [UIView animateWithDuration:0.3 animations:^{
            [self.photoCollection setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.photoCollection setContentOffset:CGPointMake(contentOffsetX, 0)];
        } completion:^(BOOL finished) {
            complete();
        }];
    });
}

@end