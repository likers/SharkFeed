//
//  OpenAnimator.m
//  SharkFeed
//
//  Created by Jinhuan Li on 8/14/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenAnimator.h"


@implementation OpenAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

/**
 *  TODO: Add user interactable transition for navigation back to collection view
 *
 *  @param transitionContext
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController<TransitionProtocol> *toViewController = (id)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<TransitionProtocol> *fromViewController = (id)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = [fromViewController view];
    UIView *toView = [toViewController view];
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    
    /**
     *  fix for rotation bug in iOS 9
     */
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    
    /**
     *  view for transition
     */
    UIView *toZoomView = [toViewController viewForTransition];
    UIView *fromZoomView = [fromViewController viewForTransition];
    
    /**
     *  check trans direction
     */
    BOOL isFromListToDetail = fromZoomView.frame.size.width < toZoomView.frame.size.width;
    
    /**
     *  make animatingImageView
     */
    UIImageView *animatingImageView = [[UIImageView alloc] initWithImage:[fromViewController imageToTrans]];
    animatingImageView.frame = CGRectIntegral([fromZoomView.superview convertRect:fromZoomView.frame toView:containerView]);
    animatingImageView.contentMode = UIViewContentModeScaleAspectFill;
    animatingImageView.clipsToBounds = YES;
    
    /**
     *  hide original zoom views
     */
    fromZoomView.alpha = 0;
    toZoomView.alpha = 0;
    
    /**
     *  add animating background view
     */
    UIImageView *backgroundView = [self snapshotImageViewFromView:fromView];
    [containerView addSubview:backgroundView];
    
    /**
     *  add animating image view
     */
    [containerView addSubview:animatingImageView];
    
    /**
     *  animation
     */
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        animatingImageView.frame = CGRectIntegral([toZoomView.superview convertRect:toZoomView.frame toView:containerView]);
        animatingImageView.contentMode = isFromListToDetail ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [animatingImageView removeFromSuperview];
        [backgroundView removeFromSuperview];
        fromZoomView.alpha = 1;
        toZoomView.alpha = 1;
    }];
}

/**
 *  Get snapshot for view, avoid changing the origin view when animating
 *
 *  @param view view
 *
 *  @return snapshot imageview
 */
-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [view takeSnapshot];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    return imageView;
}

@end