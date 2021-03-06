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
#import "OpenAnimator.h"


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
    self.navigationController.delegate = self;
    
    /**
     *  register for 3D Touch (if available)
     */
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
    }
    
    [self initNavigationBar];
    [self initData];
    
    /**
     *  Add observer for app reactive from background, reload view to update nscache
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

/**
 *  initial self-defined navigation bar
 *  TODO: hide/show navigation bar when scroll up/down
 */
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

/**
 *  instances, constants, data initializations
 */
- (void)initData {
    currentPage = 1;
    viewMargin = 21;
    
    /**
     *  Calculate cell size to keep 3 cells per row under different screen sizes
     */
    cellSize = (deviceWidth - viewMargin*2 - 6*2)/3;
    
    isLoadingMore = NO;
    photoArray = [[NSMutableArray alloc] init];
    imageCache = [[NSCache alloc] init];
    pendingDownloadDic = [[NSMutableDictionary alloc] init];
    downloadQueue = [[NSOperationQueue alloc] init];
    downloadQueue.maxConcurrentOperationCount = 5;
    
    /**
     *  Get first page Data
     */
    [self getDataForPage:currentPage isRefresh:NO];
}

/**
 *  Fetch data from Flickr server
 *
 *  @param page            the page of data
 *  @param isPullToRefresh check if the request is refreshing first page
 */
- (void)getDataForPage:(NSInteger) page isRefresh:(BOOL) isPullToRefresh{
    JLApi *api = [[JLApi alloc] init];
    [api searchSharkForPage:page completion:^(NSData *data, NSInteger statusCode) {
        if (statusCode == 200) {
            [self cancelAllDownloads];
            NSError* error;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
            /**
             *  if the request is refreshing, clear photo array
             */
            if (isPullToRefresh) {
                [photoArray removeAllObjects];
            }
            
            for (NSDictionary *dic in [[result objectForKey:@"photos"] objectForKey:@"photo"]) {
                PhotoModel *photo = [[PhotoModel alloc] init];
                [photo setPhotoModelWithDic:dic];
                [photoArray addObject:photo];
            }
            
            if (page == 1) {
                if (!isPullToRefresh) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self initCollectionView];
                    });
                } else if (isPullToRefresh) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [refreshView stopAnimating:^{
                            [self resumeScrollViewUp:self.photoCollection completion:^{
                                [self.photoCollection reloadData];
                            }];
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

/**
 *  initialization the collectionview
 */
- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 6;
    flowLayout.minimumLineSpacing = 6;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, viewMargin, 0, viewMargin);
    
    photoCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    photoCollection.delegate = self;
    photoCollection.dataSource = self;
    photoCollection.backgroundColor = [UIColor whiteColor];
    [photoCollection registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:photoCollection];
    
    [photoCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(navBarHeight);
    }];
    
    /**
     Add custom pull to refresh view to photoCollection view's top edge
     
     - returns: SFPullToRefreshView
     */
    refreshView = [[SFPullToRefreshView alloc] initWithFrame:CGRectMake(0, -SFPullToRefreshViewHeight, photoCollection.frame.size.width, SFPullToRefreshViewHeight)];
    [photoCollection addSubview:refreshView];
    
    /**
     *  Set initial contentinset for photoCollection view, add a 21 margin on top
     */
    [photoCollection setContentInset:UIEdgeInsetsMake(viewMargin, 0, 0, 0)];
}

#pragma mark - collectionView datasource and delegation
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [photoArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoModel *photo = [photoArray objectAtIndex:indexPath.row];
    
    /**
     *  If the data has no large image, use the origin image.
     */
    NSString *urlLarge = [photo.urlCommon isEqualToString:@""] ? photo.urlOrigin : photo.urlCommon;
    
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.imageView.image = nil;
    
    /**
     *  Prefer large image in cache
     */
    if ([self.imageCache objectForKey:urlLarge] != nil) {
        cell.imageView.image = [self.imageCache objectForKey:urlLarge];
    } else {
        if ([self.imageCache objectForKey:photo.urlTiny] != nil) {
            cell.imageView.image = [self.imageCache objectForKey:photo.urlTiny];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"PlaceHolder"];
            [self downloadForUrlLow:photo.urlTiny High:urlLarge Index:indexPath];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(cellSize, cellSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoModel *photo = [photoArray objectAtIndex:indexPath.row];
    NSString *url = [photo.urlCommon isEqualToString:@""] ? photo.urlOrigin : photo.urlCommon;
    selectedIndex = indexPath;
    if ([imageCache objectForKey:url] != nil) {
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        detailVC.photo = photo;
        detailVC.lowResImage = [imageCache objectForKey:url];
        detailVC.transitioningDelegate = self;
        [self presentViewController:detailVC animated:YES completion:^{}];
    }
}

/**
 *  Infinite scrolling implementation. If current cell is the 51th in 100, load more
 *  TODO: Refactor to use scrollviewdelegate, may get better performance
 */
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!isLoadingMore && [photoArray count] - (indexPath.row+1) < 50) {
        currentPage += 1;
        isLoadingMore = YES;
        [self cancelAllDownloads];
        [self getDataForPage:currentPage isRefresh:NO];
    }
}

#pragma mark - imageDownloader
/**
 *  Image Downloader
 *
 *  @param lowurl    low resolution image
 *  @param highurl   high resolution image
 *  @param indexPath indexPath of the cell being downloaded
 */
- (void)downloadForUrlLow:(NSString *)lowurl High:(NSString *)highurl Index:(NSIndexPath *)indexPath {
    if ([pendingDownloadDic objectForKey:indexPath] != nil) {
        return;
    } else {
        ImageDownloadOperation *lowdownloader = [[ImageDownloadOperation alloc] initWithUrl:lowurl Cache:self.imageCache];
        lowdownloader.completionBlock = ^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                @try
                {
                    [pendingDownloadDic removeObjectForKey:indexPath];
                    
                    /**
                     *  Unless there is no api data requests, update the cell
                     */
                    if (!isLoadingMore && refreshView.state == SFPullToRefreshStateStopped) {
                        [self.photoCollection reloadItemsAtIndexPaths:@[indexPath]];
                    }
                }
                @catch (NSException *except)
                {
                    NSLog(@"DEBUG: failure to insertItemsAtIndexPaths.  %@", except.description);
                }
            }];
        };
        [pendingDownloadDic setObject:lowdownloader forKey:indexPath];
        [downloadQueue addOperation:lowdownloader];
        
        ImageDownloadOperation *highdownloader = [[ImageDownloadOperation alloc] initWithUrl:highurl Cache:self.imageCache];
        highdownloader.completionBlock = ^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                @try
                {
                    [pendingDownloadDic removeObjectForKey:indexPath];
                    if (!isLoadingMore && refreshView.state == SFPullToRefreshStateStopped) {
                        [self.photoCollection reloadItemsAtIndexPaths:@[indexPath]];
                    }
                }
                @catch (NSException *except)
                {
                    NSLog(@"DEBUG: failure to insertItemsAtIndexPaths.  %@", except.description);
                }
            }];
        };
        [highdownloader addDependency:lowdownloader];
        [pendingDownloadDic setObject:highdownloader forKey:indexPath];
        [downloadQueue addOperation:highdownloader];
    }
}

/**
 *  When cell went off screen, cancel the download operation
 */
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

/**
 *  Cancel all operations, clear pending dictionary
 */
- (void)cancelAllDownloads {
    for (NSIndexPath *path in pendingDownloadDic) {
        [[pendingDownloadDic objectForKey:path] cancel];
    }
    [pendingDownloadDic removeAllObjects];
}

#pragma mark - ScrollView delegate
/**
 *  Check content offset to perform pull to refresh
 *
 *  @param scrollView photoCollection
 */
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY <= -60 && refreshView.state == SFPullToRefreshStateStopped) {
        [self pullScrollViewDown:scrollView completion:^{
            refreshView.state = SFPullToRefreshStateLoading;
            [refreshView startAnimating];
            [self cancelAllDownloads];
            [self getDataForPage:1 isRefresh:YES];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self cancelOffscreenCells];
}

/**
 *  Move collection view down to show SFPullToRefreshView when pull to refresh triggerd
 *
 *  @param scrollView photoCollection
 *  @param complete   comepletion block
 */
- (void)pullScrollViewDown:(UIScrollView *)scrollView completion:(void(^)(void))complete {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    refreshView.state = SFPullToRefreshStateTriggered;
    [scrollView setContentInset:UIEdgeInsetsMake(SFPullToRefreshViewHeight, 0, 0, 0)];
    [UIView animateWithDuration:0.3 animations:^{
        [scrollView setContentOffset:CGPointMake(contentOffsetX, -SFPullToRefreshViewHeight)];
    } completion:^(BOOL finished) {
        complete();
    }];
}

/**
 *  Resume collection view after data is feched and ready to reload
 *
 *  @param scrollView photoCollection
 *  @param complete   completion block
 */
- (void)resumeScrollViewUp:(UIScrollView *)scrollView completion:(void(^)(void))complete {
    refreshView.state = SFPullToRefreshStateStopped;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat contentOffsetX = self.photoCollection.contentOffset.x;
        [UIView animateWithDuration:0.3 animations:^{
            [self.photoCollection setContentInset:UIEdgeInsetsMake(viewMargin, 0, 0, 0)];
            [self.photoCollection setContentOffset:CGPointMake(contentOffsetX, -viewMargin)];
        } completion:^(BOOL finished) {
            complete();
        }];
    });
}

#pragma mark - Custom navigation transition and delegates
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[OpenAnimator alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[OpenAnimator alloc] init];
}

- (UIView *)viewForTransition {
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[self.photoCollection cellForItemAtIndexPath:selectedIndex];
    return cell.imageView;
}

- (CGRect)rectForViewToTrans {
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[self.photoCollection cellForItemAtIndexPath:selectedIndex];
    return cell.frame;
}

- (UIImage *)imageToTrans {
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[self.photoCollection cellForItemAtIndexPath:selectedIndex];
    return cell.imageView.image;
}

#pragma mark - 3D touch related
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [photoCollection indexPathForItemAtPoint:location];
    HomeCollectionViewCell *cell = [photoCollection dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    PhotoModel *photo = [photoArray objectAtIndex:indexPath.row];
    NSString *url = [photo.urlCommon isEqualToString:@""] ? photo.urlOrigin : photo.urlCommon;
    selectedIndex = indexPath;
    
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.photo = photo;
    detailVC.lowResImage = [imageCache objectForKey:url];
    [previewingContext setSourceRect:cell.frame];
    return detailVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark - Handle notifications
/**
 *  Reload photoCollection to refresh photo cache
 *  TODO: use local storage to keep nacache
 *
 *  @param note NSNotification
 */
-(void)appWillActive:(NSNotification*)note
{
    [photoCollection reloadData];
}
-(void)appWillTerminate:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}

@end