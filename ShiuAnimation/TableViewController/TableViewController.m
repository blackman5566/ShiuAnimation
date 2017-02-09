
//
//  ViewController.m
//  ShiuAnimation
//
//  Created by AllenShiu on 2017/1/20.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "DetailViewController.h"
#import "CollectionViewCell.h"
#import "BrowseAnimation.h"

typedef NS_OPTIONS(NSInteger, SnapShotType) {
    SnapShotTypeUp = 1 << 1, // 剪裁上半部分
    SnapShotTypeDown = 1 << 2, // 剪裁下半部分
};

#define  ScreenWidth   [UIScreen mainScreen].bounds.size.width
#define  ScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface TableViewController ()<TableViewCellDelegate,UITableViewDataSource,UITableViewDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic,strong)NSMutableArray *items;
@property (nonatomic,strong)BrowseAnimation *browseAnimation;
@property (weak, nonatomic)IBOutlet UITableView *tableView;

@end

@implementation TableViewController

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.browseAnimation.styleType = StyleTypeFadeIn;
    return self.browseAnimation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.browseAnimation.styleType = StyleTypeDismissNone;
    return self.browseAnimation;
}

#pragma mark - TableViewCellDelegate

-(void)collectionViewDidSelectedItemIndexPath:(NSIndexPath *)indexPath collcetionView:(UICollectionView *)collectionView forCell:(TableViewCell *)cell{
    
    // 獲得 collectionView 點擊 cell 的 imageView
    CollectionViewCell *collectionCell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = collectionCell.petImageView;
    CGRect tapImageViewFrame = [imageView.superview convertRect:imageView.frame toView:nil];
    CGFloat tapY = tapImageViewFrame.origin.y;
    CGFloat downY = tapImageViewFrame.origin.y + tapImageViewFrame.size.height;
    
    // 上方圖片與下方圖片開始的 Frame
    CGRect topImageViewOriginalFrame = CGRectMake(0, 0, ScreenWidth, tapY);
    CGRect downImageViewOriginalFrame = CGRectMake(0, downY, ScreenWidth, ScreenHeight - downY);
    
    // 上方圖片與下方圖片結束的 Frame
    CGRect topImageViewEndFrame = CGRectMake(0, -tapY, ScreenWidth, tapY);
    CGRect downImageViewEndFrame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - downY);
    
    // 獲得當前畫面的 image ，與上方跟下方的 image
    UIImage *snapImage = [self snapShotToImage];
    UIImage *topImage = [self separationImage:snapImage point:tapY snapShotType:SnapShotTypeUp];
    UIImage *downImage = [self separationImage:snapImage point:downY snapShotType:SnapShotTypeDown];
    
    // 上方的圖片
    UIImageView *topAnimationImageView = UIImageView.new;
    topAnimationImageView.frame = topImageViewOriginalFrame;
    topAnimationImageView.image = topImage;
    [self.view.window addSubview:topAnimationImageView];
    
    // 下方的圖片
    UIImageView *downAnimationImageView = UIImageView.new;
    downAnimationImageView.frame = downImageViewOriginalFrame;
    downAnimationImageView.image = downImage;
    [self.view.window addSubview:downAnimationImageView];
    
    // 中間部分的圖片
    NSDictionary *collectionViewImageViewsInfo = [self findImageViewsFromCollectionView:collectionView];
    NSMutableArray *imageViewOriginalFrames = collectionViewImageViewsInfo[@"collectionViewImageViewsFrame"];
    
    // 計算中間部分圖片的結束位置
    NSMutableArray *imageViewEndFrames = [self calculateEndFrameWithImageViewOriginalFrames:imageViewOriginalFrames tapImageViewFrame:tapImageViewFrame];
    
    // 動畫開始
    __weak TableViewController *weakSelf = self;
    __block NSMutableArray *collectionViewImageViews = collectionViewImageViewsInfo[@"collectionViewImageViews"];
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
    
        // 上方的圖片往上移動
        topAnimationImageView.frame = topImageViewEndFrame;
        
        // 下方的圖片往下移動
        downAnimationImageView.frame = downImageViewEndFrame;
        
        // collectionView 每個 cell 圖片，設定結束的 frame
        for (NSInteger index = 0; index < collectionViewImageViews.count; index++) {
            UIImageView *imageView = collectionViewImageViews[index];
            NSValue *value = imageViewEndFrames[index];
            CGRect rect = value.CGRectValue;
            imageView.frame = rect;
        }
        
        // tableview 隱藏起來
        weakSelf.tableView.hidden = YES;
    }completion:^(BOOL finished) {
        // 自定義動畫效果
        DetailViewController *detailViewController = [[DetailViewController alloc] init];
        detailViewController.selectImage = collectionCell.petImageView.image;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        navigationController.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)self;
        navigationController.modalPresentationStyle = UIModalPresentationCustom;
        
        // 設定結束時動畫
        detailViewController.closeBlock = [weakSelf closeAnimationWithTopImage:topImage
                                                     topImageViewOriginalFrame:topImageViewOriginalFrame
                                                          topImageViewEndFrame:topImageViewEndFrame
                                                                     downImage:downImage
                                                    downImageViewOriginalFrame:downImageViewOriginalFrame
                                                         downImageViewEndFrame:downImageViewEndFrame
                                                                 visiableCells:collectionView.visibleCells
                                                            imageViewEndFrames:imageViewEndFrames
                                                       imageViewOriginalFrames:imageViewOriginalFrames
                                                         presentViewController:detailViewController];
        
        // 將 DetailViewController 顯示出來
        [weakSelf presentViewController:navigationController animated:YES completion: ^{
            // 當完成動畫時清除動畫圖片
            [topAnimationImageView removeFromSuperview];
            [downAnimationImageView removeFromSuperview];
            for (UIImageView *imageView in collectionViewImageViews) {
                [imageView removeFromSuperview];
            }
            collectionViewImageViews = nil;
        }];
    }];
}

-(CloseBlock)closeAnimationWithTopImage:(UIImage *)topImage
              topImageViewOriginalFrame:(CGRect)topImageViewOriginalFrame
                   topImageViewEndFrame:(CGRect)topImageViewEndFrame
                              downImage:(UIImage *)downImage
             downImageViewOriginalFrame:(CGRect)downImageViewOriginalFrame
                  downImageViewEndFrame:(CGRect)downImageViewEndFrame
                          visiableCells:(NSArray *)visibleCells
                     imageViewEndFrames:(NSArray *)imageViewEndFrames
                imageViewOriginalFrames:(NSArray *)imageViewOriginalFrames
                  presentViewController:(DetailViewController *)detailViewController
{
    // 設定關閉 block
    CloseBlock closeBlock = ^(){
        
        // 上方的圖片
        UIImageView *topAnimationImageView = [[UIImageView alloc] init];
        topAnimationImageView.frame = topImageViewEndFrame;
        topAnimationImageView.image = topImage;
        [detailViewController.view.window addSubview:topAnimationImageView];
    
        // 下方的圖片
        UIImageView *downAnimationImageView = [[UIImageView alloc] init];
        downAnimationImageView.frame = downImageViewEndFrame;
        downAnimationImageView.image = downImage;
        [detailViewController.view.window addSubview:downAnimationImageView];
        
        // collectionView 每個 cell 圖片，設定結束的 frame
        __block NSMutableArray *animationImageViews = [NSMutableArray array];
        for (NSInteger index = 0; index < visibleCells.count; index++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [animationImageViews addObject:imageView];
            NSValue *value = imageViewEndFrames[index];
            CGRect rect = [value CGRectValue];
            imageView.frame = rect;
            CollectionViewCell *collectionCell = visibleCells[index];
            imageView.image = collectionCell.petImageView.image;
            [detailViewController.view.window addSubview:imageView];
        }
        
        // 動畫開始
        __weak TableViewController *weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // 上方的圖片往下移動
            topAnimationImageView.frame = topImageViewOriginalFrame;
            
            // 下方的圖片往上移動
            downAnimationImageView.frame = downImageViewOriginalFrame;
            
            // collectionView 每個 cell 圖片，設定結束的 frame
            for (NSInteger index = 0; index < animationImageViews.count; index++) {
                UIImageView *imageView = animationImageViews[index];
                NSValue *value = imageViewOriginalFrames[index];
                CGRect rect = value.CGRectValue;
                imageView.frame = rect;
            }
            
            // 詳細頁面的 view 隱藏
            detailViewController.view.hidden = YES;
        }completion:^(BOOL finished) {
            
            // 當完成動畫時清除動畫圖片
            [topAnimationImageView removeFromSuperview];
            [downAnimationImageView removeFromSuperview];
            for (UIImageView *imageView in animationImageViews) {
                [imageView removeFromSuperview];
            }
            animationImageViews = nil;
            
            // 詳細頁面 dismis 掉
            [detailViewController dismissViewControllerAnimated:YES completion:nil];
            
            // tbleView 與 navigationBar 顯示出來。
            weakSelf.tableView.hidden = NO;
            weakSelf.navigationController.navigationBar.hidden = NO;
        }];
    };
    return closeBlock;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = [NSString stringWithFormat:@"貓咪紅牌 第 %ld 區",(long)indexPath.row+1];
    cell.items = self.items[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - private instance method

#pragma mark * init

- (void)setupBrowseAnimation {
    self.browseAnimation = [BrowseAnimation new];
}

-(void)setupInitValue{
    self.title = @"貓貓紅牌榜";
}

-(void)setupTableView{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCell class]) bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    [self.tableView reloadData];
}

-(void)setupTableViewData{
    self.items = [NSMutableArray new];
    NSArray *items1 = @[@"1",@"2",@"3",@"4",@"5"];
    NSArray *items2 = @[@"6",@"7",@"8",@"9",@"10"];
    NSArray *items3 = @[@"11",@"12",@"13",@"14",@"15"];
    [self.items addObject:items1];
    [self.items addObject:items2];
    [self.items addObject:items3];
}

#pragma mark * misc

-(UIImage *)snapShotToImage{
    // 將目前的畫面製作成圖片
    UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, self.view.window.opaque, 0);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aImage;
}

-(UIImage *)separationImage:(UIImage *)image point:(CGFloat)tapImageViewTopY snapShotType:(SnapShotType)snapShotType{
    // 將圖片剪裁
    // 因為是取得點擊圖片的最小的 y 值，所以會有兩種情況必須要做判斷
    // 第一種：tapImageViewTopY 必須要大於 0 ，如果小於 0 的話代表點擊的圖片上半部份超出螢幕外面，所以就不做剪裁動作。
    // 第二種：tapImageViewTopY 必須要小於 imageSize.height，如果大於 imageSize.height 的話代表點擊的圖片下半部份超出螢幕外面，所以就不做剪裁動作。
    CGSize imageSize = image.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = CGRectNull;
    
    BOOL isOverTopScreen = tapImageViewTopY > 0;
    BOOL isOverDownScreen = tapImageViewTopY < imageSize.height;
    if (isOverTopScreen && isOverDownScreen){
        switch (snapShotType) {
            case SnapShotTypeUp:
                rect = CGRectMake(0, 0, imageSize.width * scale, tapImageViewTopY * scale);
                break;
            case SnapShotTypeDown:
                rect = CGRectMake(0, tapImageViewTopY * scale, imageSize.width * scale, (imageSize.height - tapImageViewTopY) * scale);
                break;
        }
        CGImageRef sourceImageRef = [image CGImage];
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
        return newImage;
    }
    return nil;
}

-(NSDictionary *)findImageViewsFromCollectionView:(UICollectionView *)collectionView {
    
    NSArray *cells = collectionView.visibleCells;
    NSMutableArray *collectionViewImageViews = [NSMutableArray arrayWithCapacity:cells.count];
    NSMutableArray *collectionViewImageViewsFrame = [NSMutableArray arrayWithCapacity:cells.count];
    for (CollectionViewCell *cell in cells) {
        // 轉換 frame
        CGRect rect = [cell.petImageView.superview convertRect:cell.petImageView.frame toView:nil];
        NSValue *value = [NSValue valueWithCGRect:rect];
        [collectionViewImageViewsFrame addObject:value];
        
        // 將中間部分目前可視的 cell 拆成圖片並加入至 collectionViewImageViews，讓待會動畫時好處理。
        UIImageView *animationImageView = [UIImageView new];
        animationImageView.image = cell.petImageView.image;
        animationImageView.frame = rect;
        [self.view.window addSubview:animationImageView];
        [collectionViewImageViews addObject:animationImageView];
    }
    // collectionViewImageViews:存放中間部分目前可視的 cell 圖片
    // collectionViewImageViewsFrame :存放中間部分目前可視的 cell 圖片 frame
    return @{@"collectionViewImageViews" : collectionViewImageViews,@"collectionViewImageViewsFrame" : collectionViewImageViewsFrame};
}

-(NSMutableArray *)calculateEndFrameWithImageViewOriginalFrames:(NSArray *)imageViewOriginalFrames tapImageViewFrame:(CGRect)tapImageViewFrame{
    // 中間圖片高度 2:3
    CGRect tapImageViewEndFrame = CGRectMake(0, 0, ScreenWidth, ScreenWidth * 2.0 / 3.0);
    NSMutableArray *animationEndFrames = [NSMutableArray arrayWithCapacity:imageViewOriginalFrames.count];
    
    // 開始計算
    for (NSInteger index = 0; index < imageViewOriginalFrames.count; index++) {
        NSValue *value = imageViewOriginalFrames[index];
        CGRect rect = [value CGRectValue];
        CGRect targetRect = tapImageViewEndFrame;
        
        // 判斷目前圖片是在點擊圖片的左側還右側
        BOOL isTapImageViewLeft = rect.origin.x < tapImageViewFrame.origin.x;
        BOOL isTapImageViewRight = rect.origin.x > tapImageViewFrame.origin.x;
        if (isTapImageViewLeft) {
            // 在左邊
            CGFloat detla = tapImageViewFrame.origin.x - rect.origin.x;
            targetRect.origin.x = -(detla * ScreenWidth) / tapImageViewFrame.size.width;
        }else if (isTapImageViewRight) {
            // 在右邊
            CGFloat detla = rect.origin.x - tapImageViewFrame.origin.x;
            targetRect.origin.x = (detla * ScreenWidth) / tapImageViewFrame.size.width;
        }
        // 儲存起來
        NSValue *targetValue = [NSValue valueWithCGRect:targetRect];
        [animationEndFrames addObject:targetValue];
    }
    
    return animationEndFrames;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValue];
    [self setupTableView];
    [self setupTableViewData];
    [self setupBrowseAnimation];
}
@end
