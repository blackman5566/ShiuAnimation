//
//  BrowseAnimation.h
//  testFeature
//
//  Created by 許佳豪 on 2017/1/9.
//  Copyright © 2017年 許佳豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

typedef NS_ENUM(NSInteger, StyleType) {
    StyleTypeDefault,
    StyleTypeFadeIn,
    StyleTypeDismiss,
    StyleTypeDismissNone
};

@interface BrowseAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) StyleType styleType;

@end
