//
//  TableViewCell.h
//  ShiuAnimation
//
//  Created by AllenShiu on 2017/1/23.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableViewCellDelegate;

@interface TableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray *items;

@property(nonatomic, weak)id<TableViewCellDelegate> delegate;

@end

@protocol TableViewCellDelegate <NSObject>
@optional
-(void)collectionViewDidSelectedItemIndexPath:(NSIndexPath *)indexPath collcetionView:(UICollectionView *)collectionView forCell:(TableViewCell *)cell;

@end
