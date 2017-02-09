//
//  BrowseAnimation.m
//  testFeature
//
//  Created by 許佳豪 on 2017/1/9.
//  Copyright © 2017年 許佳豪. All rights reserved.
//


#import "BrowseAnimation.h"

#define screen_width CGRectGetWidth([UIScreen mainScreen].bounds)
#define screen_height CGRectGetHeight([UIScreen mainScreen].bounds)

@implementation BrowseAnimation

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect frame = CGRectMake(0, 0, screen_width, screen_height);
    
    switch (self.styleType) {
        case StyleTypeDefault:
        {
            toViewController.view.frame = frame;
            UIView *container = [transitionContext containerView];
            [container insertSubview:toViewController.view belowSubview:fromViewController.view];
            [transitionContext completeTransition:YES];
            break;
        }
            
        case StyleTypeFadeIn:
        {
            toViewController.view.frame = frame;
            UIView *container = [transitionContext containerView];
            [container insertSubview:toViewController.view belowSubview:fromViewController.view];
            
            toViewController.view.alpha = 0;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
                toViewController.view.alpha = 1;
            } completion: ^(BOOL finished) {
                toViewController.view.alpha = 1;
                [transitionContext completeTransition:YES];
            }];
            break;
        }
            
        case StyleTypeDismiss:
        {
            CGRect dismissFrame = frame;
            dismissFrame.origin.y += screen_height;
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
                fromViewController.view.frame = dismissFrame;
            } completion: ^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
            break;
        }
            
        case StyleTypeDismissNone:
        {
            fromViewController.view.frame = CGRectZero;
            [transitionContext completeTransition:YES];
            break;
        }
            
        default:
            break;
    }
}

@end
