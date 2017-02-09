//
//  CollectionViewCell.m
//  ShiuAnimation
//
//  Created by AllenShiu on 2017/1/23.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.petImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.petImageView.layer.borderWidth = 3.0f;
}

@end
