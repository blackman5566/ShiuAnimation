//
//  DetailViewController.h
//  ShiuAnimation
//
//  Created by AllenShiu on 2017/1/23.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseBlock)();

@interface DetailViewController : UIViewController

/**
 @abstract 使用者選擇的 cell 圖片
 */
@property(nonatomic, strong)UIImage *selectImage;

/**
 @abstract 關閉 Block
 */
@property(nonatomic, strong)CloseBlock closeBlock;

@end

