//
//  UIView+Shiu.m
//  ShiuAnimation
//
//  Created by AllenShiu on 2017/2/9.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

#import "UIView+Shiu.h"

@implementation UIView (Shiu)

- (NSLayoutConstraint *)constraintTopWithSuper {
    // 尋找 top 的 constraint
    for (NSLayoutConstraint *constraint in self.superview.constraints) {
        BOOL isThisItem = constraint.firstItem == self || constraint.secondItem == self;
        BOOL isConstraint = constraint.firstAttribute == NSLayoutAttributeTop || constraint.secondAttribute == NSLayoutAttributeTop;
        if (isThisItem && isConstraint) {
            return constraint;
        }
    }
    NSLog(@"No find this constraint");
    return nil;
}

@end
