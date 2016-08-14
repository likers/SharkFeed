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

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController<TransitionProtocol> *toViewController = (id)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<TransitionProtocol> *fromViewController = (id)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = [fromViewController view];
    UIView *toView = [toViewController view];
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    
    // fix for rotation bug in iOS 9
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    
    // view for transition
    
    UIView *toZoomView = [toViewController viewForTransition];
    UIView *fromZoomView = [fromViewController viewForTransition];
    
    UIImageView *animatingImageView = [self initialZoomSnapshotFromView:fromZoomView destinationView:toZoomView];
    animatingImageView.frame = CGRectIntegral([fromZoomView.superview convertRect:fromZoomView.frame toView:containerView]);
    
    // hide original zoom views
    fromZoomView.alpha = 0;
    toZoomView.alpha = 0;
    
    // add animating background view
    UIImageView *backgroundView = [self snapshotImageViewFromView:fromView];
    [containerView addSubview:backgroundView];
    
    // add animating image view
    [containerView addSubview:animatingImageView];
    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
//        toViewController.view.alpha = 1;
//    } completion:^(BOOL finished) {
//        fromViewController.view.transform = CGAffineTransformIdentity;
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        
//    }];
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        animatingImageView.frame = CGRectIntegral([toZoomView.superview convertRect:toZoomView.frame toView:containerView]);
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [animatingImageView removeFromSuperview];
        [backgroundView removeFromSuperview];
        fromZoomView.alpha = 1;
        toZoomView.alpha = 1;
    }];
}

-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [view takeSnapshot];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    return imageView;
}

-(UIImageView *)initialZoomSnapshotFromView:(UIView *)sourceView
                            destinationView:(UIView *)destinationView
{
    return [self snapshotImageViewFromView:(sourceView.bounds.size.width > destinationView.bounds.size.width) ? sourceView : destinationView];
}

@end