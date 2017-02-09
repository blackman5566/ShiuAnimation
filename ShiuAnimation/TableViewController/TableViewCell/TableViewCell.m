//
//  TableViewCell.m
//  ShiuAnimation
//
//  Created by AllenShiu on 2017/1/23.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

#import "TableViewCell.h"
#import "CollectionViewCell.h"

@implementation TableViewCell

#pragma mark - Set

-(void)setItems:(NSArray *)items{
    _items = items;
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(collectionViewDidSelectedItemIndexPath:collcetionView:forCell:)]) {
        [self.delegate collectionViewDidSelectedItemIndexPath:indexPath collcetionView:collectionView forCell:self];
    }
}

#pragma mark UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.petImageView.image = [UIImage imageNamed:self.items[indexPath.row]];
    return cell;
}

#pragma mark - setup

-(void)setupCollectionView{
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    self.collectionView.collectionViewLayout = [self setupCollectionViewFlowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
}

-(UICollectionViewFlowLayout*)setupCollectionViewFlowLayout{
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc]init];
    collectionViewLayout.itemSize = CGSizeMake(300,236);
    collectionViewLayout.minimumInteritemSpacing = 0;
    collectionViewLayout.minimumLineSpacing = 0;
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return collectionViewLayout;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupCollectionView];
}

@end
