//
//  MCOShopManagerTabVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOShopManagerTabVC.h"
#import "MCOSquareCell.h"
#import "MCOSquareItem.h"
#import "MCOUploadGood.h"
#import "MCOShopPropagandaVC.h"
#import "MCOShopDynamicViC.h"
#import "MCShopMsgOVC.h"
#import "MCOShopClassify.h"
#import "MCOShopManOrderView.h"
#import "MCORefRecordVC.h"
static NSString * const ID = @"cell";
static NSInteger const cols = 4;
static CGFloat const margin = 2;
#define MCOScreenW [UIScreen mainScreen].bounds.size.width
#define MCOScreenH [UIScreen mainScreen].bounds.size.height
#define itemWH (MCOScreenW - (cols - 1) * margin) / cols

@interface MCOShopManagerTabVC ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *squareItems;
@end

@implementation MCOShopManagerTabVC

-(NSMutableArray *)squareItems
{
    if(_squareItems == nil)
    {
        _squareItems = [NSMutableArray array];
    }
    return _squareItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];

    // 设置tableView底部视图
    [self setupFootView];
    
    // 加载数据
    [self loadData];
    
    // 处理cell间距,默认tableView分组样式,有额外头部和尾部间距
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 5;
    
    self.tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0);
}

#pragma mark - 加载数据
- (void)loadData
{
    MCOSquareItem *item0 = [[MCOSquareItem alloc] init];
    item0.name = @"订单管理";
    item0.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    MCOSquareItem *item1 = [[MCOSquareItem alloc] init];
    item1.name = @"商品上架";
    item1.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    MCOSquareItem *item2 = [[MCOSquareItem alloc] init];
    item2.name = @"商品管理";
    item2.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    MCOSquareItem *item3 = [[MCOSquareItem alloc] init];
    item3.name = @"首页宣传";
    item3.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    MCOSquareItem *item4 = [[MCOSquareItem alloc] init];
    item4.name = @"店铺动态";
    item4.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    MCOSquareItem *item5 = [[MCOSquareItem alloc] init];
    item5.name = @"短信公告";
    item5.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    MCOSquareItem *item6 = [[MCOSquareItem alloc] init];
    item6.name = @"提现管理";
    item6.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    [self.squareItems addObject:item0];
    [self.squareItems addObject:item1];
    [self.squareItems addObject:item2];
    [self.squareItems addObject:item3];
    [self.squareItems addObject:item4];
    [self.squareItems addObject:item5];
    [self.squareItems addObject:item6];
    // 设置collectionView 计算collectionView高度 = rows * itemWH
    // Rows = (count - 1) / cols + 1  3 cols4
    NSInteger count = _squareItems.count;
    NSInteger rows = (count - 1) / cols + 1;
    // 设置collectioView高度
    CGRect frame = self.collectionView.frame;
    frame.size.height = rows * itemWH;
    self.collectionView.frame =frame;
    // 设置tableView滚动范围:自己计算
    self.tableView.tableFooterView = self.collectionView;
    // 刷新表格
    [self.collectionView reloadData];
    
}

- (void)setupNavBar
{
    // titleView
    self.navigationItem.title = @"商家管理";
    
}

#pragma mark - 设置tableView底部视图
- (void)setupFootView
{
    /*
     1.初始化要设置流水布局
     2.cell必须要注册
     3.cell必须自定义
     */
    //创建布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置cell尺寸
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    //创建uicollectionview
    UICollectionView *collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 300) collectionViewLayout:layout];
    _collectionView = collectView;
    collectView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = collectView;
    
    //设置代理
    collectView.dataSource = self;
    collectView.delegate = self;
    //设置不能滚动
    collectView.scrollEnabled = NO;
    
    // 注册cell
    [collectView registerNib:[UINib nibWithNibName:@"MCOSquareCell" bundle:nil] forCellWithReuseIdentifier:ID];
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0://订单管理
        {
            MCOShopManOrderView *uploadvc = [[MCOShopManOrderView alloc] init];
            [self.navigationController pushViewController:uploadvc animated:YES];
        }
            break;
        case 1://商品上架
        {
            MCOUploadGood *uploadvc = [[MCOUploadGood alloc] init];
            [self.navigationController pushViewController:uploadvc animated:YES];
        }
            break;
        case 2://商品管理
        {
            MCOShopClassify *vc = [[MCOShopClassify alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3://首页宣传
        {
            MCOShopPropagandaVC *vc = [[MCOShopPropagandaVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4://店铺动态
        {
            MCOShopDynamicViC *vc = [[MCOShopDynamicViC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5://短信公告
        {
            MCShopMsgOVC *vc = [[MCShopMsgOVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6://提现管理
        {
            MCORefRecordVC *vc = [[MCORefRecordVC alloc] init];
            vc.status = @"1";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.squareItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 从缓存池取
    MCOSquareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.backgroundColor=[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    cell.item = self.squareItems[indexPath.row];
    return cell;
}


@end
