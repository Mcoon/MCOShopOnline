//
//  MCOShopVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOShopVC.h"
#import "UIBarButtonItem+Item.h"
#import "MCOShopSubTableViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOShopGoodItem.h"
#import "MCOShopGoodCell.h"
#import "MCOGoodDetailVC.h"
#import "MCOScrollView.h"
#import "MCOQueryTableViewController.h"
static NSString * const ID = @"cellshop";
static NSInteger const cols = 2;
static CGFloat const margin = 6;
#define MCOScreenW [UIScreen mainScreen].bounds.size.width
#define MCOScreenH [UIScreen mainScreen].bounds.size.height
#define itemW (MCOScreenW - (cols - 1) * margin) / cols
#define itemH 260

@interface MCOShopVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *shopXCView;
@property (nonatomic, strong) NSMutableArray *goodItems;
@property (nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,weak)MCOScrollView *scrollView;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCOShopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航条
    [self setupNavBar];
    
    //设置刷新
    [self setupRefresh];

    
    // 处理cell间距,默认tableView分组样式,有额外头部和尾部间距
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 5;
    
    self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    MCOScrollView *scrol = [MCOScrollView scrollView];
    scrol.frame = CGRectMake(0, 0, _shopXCView.frame.size.width, _shopXCView.frame.size.height);
    _scrollView =scrol;
    [_shopXCView addSubview:scrol];
    
  
}

- (void)setupRefresh
{
    
    // header
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, - 20, self.tableView.frame.size.width, 50);
    self.header = header;
    [self.tableView addSubview:header];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = header.bounds;
    headerLabel.backgroundColor = [UIColor lightGrayColor];
    headerLabel.text = @"下拉可以刷新";
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:headerLabel];
    self.headerLabel = headerLabel;
    
    // 让header自动进入刷新
    [self headerBeginRefreshing];
    
    
}

#pragma mark - 加载数据
//- (void)loadData
//{
//
//    // 1.创建请求会话管理者
//    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
//
//    //支持text/html
//    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//
//    //resp内容为非json处理方法
//    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppGoodsInfo" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSArray *dictarr = responseObject;
//
//        _dataArr = [MCOShopGoodItem mj_objectArrayWithKeyValuesArray:dictarr];
//
//        // 设置collectionView 计算collectionView高度 = rows * itemWH
//        // Rows = (count - 1) / cols + 1  3 cols4
//        NSInteger count = _goodItems.count;
//        NSInteger rows = (count - 1) / cols + 1;
//        // 设置collectioView高度
//        CGRect frame = self.collectionView.frame;
//        frame.size.height = rows * itemH;
//        self.collectionView.frame =frame;
////        // 设置tableView滚动范围:自己计算
////        self.tableView.tableFooterView = self.collectionView;
//        // 刷新表格
//        [self.collectionView reloadData];
//
//        // 设置tableView底部视图
//        [self setupFootView];
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////        [MBProgressHUD hideHUD];
////        [MBProgressHUD showError:@"网络错误"];
//    }];
//
//
//}

- (void)loadData2
{
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppShopXCPhotos" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(![resp isEqualToString:@"error"])
        {
            //去除最后一个分号
            resp = [resp substringToIndex:[resp length] - 1];
            _scrollView.imageNames = [resp componentsSeparatedByString:@";"];
        }
        
    } failure:nil];
    
    
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
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    //创建uicollectionview
    UICollectionView *collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, (itemH+margin) * ((_dataArr.count+1)/cols)-margin) collectionViewLayout:layout];
    _collectionView = collectView;
    collectView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = collectView;
    
    //设置代理
    collectView.dataSource = self;
    collectView.delegate = self;
    //设置不能滚动
    collectView.scrollEnabled = NO;
    
    // 注册cell
    [collectView registerNib:[UINib nibWithNibName:@"MCOShopGoodCell" bundle:nil] forCellWithReuseIdentifier:ID];
    
}

#pragma  mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    MCOQueryTableViewController *vc =[[MCOQueryTableViewController alloc] init];
    vc.key =searchBar.text;
    [self.navigationController pushViewController:vc animated:YES];
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{

    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    MCOShopGoodItem *item =self.dataArr[indexPath.row];
    
    UIStoryboard *storyboardme = [UIStoryboard storyboardWithName:NSStringFromClass([MCOGoodDetailVC class]) bundle:nil];
//      NSLog(@"%@",item.pro_id);
    //加载箭头指向控制器
    MCOGoodDetailVC *vc = [storyboardme instantiateInitialViewController];
    vc.GoodID = item.pro_id;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 从缓存池取
    MCOShopGoodCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    cell.item = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)setupNavBar
{
    
    // 左边按钮
    // 把UIButton包装成UIBarButtonItem.就导致按钮点击区域扩大
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithimage:[UIImage imageNamed:@"MainTagSubIcon"] highImage:[UIImage imageNamed:@"MainTagSubIconClick"] target:self action:@selector(leftClick)];
    
//    // 右边按钮
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithimage:[UIImage imageNamed:@"navigationButtonRandom"] highImage:[UIImage imageNamed:@"navigationButtonRandomClick"] target:nil action:@selector(rightClick)];
    
    // titleView
    UIView *searchView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    UISearchBar *bar =  [[UISearchBar alloc] initWithFrame:searchView.frame];
    bar.placeholder = @"快来搜搜您爱的宝贝～";
    //设置placeholder颜色字体
    UITextField * searchField = [bar valueForKey:@"_searchField"];
    [searchField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [searchField setValue:[UIFont boldSystemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];

    bar.delegate = self;
    [searchView addSubview:bar];
    self.navigationItem.titleView = searchView;
   
    
}

- (void)leftClick
{
    MCOShopSubTableViewController *subvc = [[MCOShopSubTableViewController alloc] init];
    
    [self.navigationController pushViewController:subvc animated:YES];
}

#pragma mark - 代理方法
/**
 *  用户松开scrollView时调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = - (self.tableView.contentInset.top + 150);
    if (self.tableView.contentOffset.y <= offsetY) { // header已经完全出现
        [self headerBeginRefreshing];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 处理header
    [self dealHeader];
    
}

/**
*  处理header
*/
- (void)dealHeader
{
    // 如果正在下拉刷新，直接返回
    if (self.isHeaderRefreshing) return;
    
    // 当scrollView的偏移量y值 <= offsetY时，代表header已经完全出现
    CGFloat offsetY = - (self.tableView.contentInset.top + 150);
    if (self.tableView.contentOffset.y <= offsetY) { // header已经完全出现
        self.headerLabel.text = @"松开立即刷新";
        //        self.headerLabel.backgroundColor = [UIColor grayColor];
    } else {
        self.headerLabel.text = @"下拉可以刷新";
        //        self.headerLabel.backgroundColor = [UIColor redColor];
    }
}


#pragma mark - header刷新
- (void)headerBeginRefreshing
{
    // 如果正在下拉刷新，直接返回
    if (self.isHeaderRefreshing) return;
    
    // 进入下拉刷新状态
    self.headerLabel.text = @"正在刷新数据...";
    //    self.headerLabel.backgroundColor = [UIColor blueColor];
    self.headerRefreshing = YES;
    // 增加内边距
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top += self.header.frame.size.height;
        self.tableView.contentInset = inset;
        
        // 修改偏移量
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x,  - inset.top);
    }];
    
    // 发送请求给服务器，下拉刷新数据
    [self loadNewTopics];
}

- (void)headerEndRefreshing
{
    self.headerRefreshing = NO;
    // 减小内边距
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top -= self.header.frame.size.height;
        self.tableView.contentInset = inset;
    }];
}

#pragma mark - 下拉刷新数据处理
/**
 *  发送请求给服务器，下拉刷新数据
 */
- (void)loadNewTopics
{
    [self loadData2];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppGoodsInfo" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOShopGoodItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        // 设置collectionView 计算collectionView高度 = rows * itemWH
        // Rows = (count - 1) / cols + 1  3 cols4
        NSInteger count = _goodItems.count;
        NSInteger rows = (count - 1) / cols + 1;
        // 设置collectioView高度
        CGRect frame = self.collectionView.frame;
        frame.size.height = rows * itemH;
        self.collectionView.frame =frame;
        //        // 设置tableView滚动范围:自己计算
        //        self.tableView.tableFooterView = self.collectionView;
        // 刷新表格
        [self.collectionView reloadData];
        
        // 设置tableView底部视图
        [self setupFootView];
        
        // 结束刷新
        [self headerEndRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 结束刷新
        [self headerEndRefreshing];
    }];
}

@end
