//
//  MCOTtrendsVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTtrendsVC.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOShopTrendItem.h"
#import "MCOTShopTrendCell.h"
#import "MCOTtrendSubVC.h"
/** UITabBar的高度 */
CGFloat const MCOTabBarH = 49;
/** 导航栏的最大Y值 */
CGFloat const MCONavMaxY = 64;
static NSString * const ID = @"trendcell";
@interface MCOTtrendsVC ()
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property(nonatomic,strong)NSMutableArray *dataArr;
/** 当前最后一条帖子数据的描述信息，专门用来加载下一页数据 */
@property (nonatomic, copy) NSString *maxtime;
/** 所有的帖子数据 */
@property (nonatomic, strong) NSMutableArray *topics;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

/** 上拉刷新控件 */
@property (nonatomic, weak) UIView *footer;
/** 上拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *footerLabel;
/** 上拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isFooterRefreshing) BOOL footerRefreshing;
@end

@implementation MCOTtrendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self setupNavBar];
    
    
    // 处理cell间距,默认tableView分组样式,有额外头部和尾部间距
    
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 10;
    
//    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, MCOTabBarH, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOTShopTrendCell" bundle:nil] forCellReuseIdentifier:ID];
    
    [self setupRefresh];
}

- (void)setupRefresh
{
    // 广告条
//    UILabel *label = [[UILabel alloc] init];
//    label.backgroundColor = [UIColor blackColor];
//    label.frame = CGRectMake(0, 0, 0, 30);
//    label.textColor = [UIColor whiteColor];
//    label.text = @"广告";
//    label.textAlignment = NSTextAlignmentCenter;
//    self.tableView.tableHeaderView = label;
    
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
    
    // footer
    UIView *footer = [[UIView alloc] init];
    footer.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 35);
    self.footer = footer;
    
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.frame = footer.bounds;
    footerLabel.backgroundColor = [UIColor lightGrayColor];
    footerLabel.text = @"上拉可以加载更多";
    footerLabel.textColor = [UIColor whiteColor];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:footerLabel];
    self.footerLabel = footerLabel;
    
    self.tableView.tableFooterView = footer;
    
    [footer setHidden:YES];
}

- (void)setupNavBar
{
    
    self.navigationItem.title = @"动态";
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCOTShopTrendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.item = _dataArr[indexPath.section];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCOShopTrendItem *item = _dataArr[indexPath.section];
    if(item.dyn_photots.length==0) return 120;
    else
    {
        //查找；个数，减去1就是图片个数
        NSArray *array = [item.dyn_photots componentsSeparatedByString:@";"];
        NSInteger count = [array count] - 1;
        if(count % 3 == 0)
        {
            count = (count/3)*125;
        }
        else
        {
            count = (count/3+1)*125;
        }
        
         return 135+count;
       
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //处理点击事件
    MCOShopTrendItem *item = _dataArr[indexPath.section];
    MCOTtrendSubVC *vc = [[MCOTtrendSubVC alloc] init];
    vc.item = item;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    // 处理footer
    [self dealFooter];
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

/**
 *  处理footer
 */
- (void)dealFooter
{
    // 还没有任何内容的时候，不需要判断
    if (self.tableView.contentSize.height == 0) return;
    
    // 当scrollView的偏移量y值 >= offsetY时，代表footer已经完全出现
    CGFloat ofsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.frame.size.height;
    if (self.tableView.contentOffset.y >= ofsetY
        && self.tableView.contentOffset.y > - (self.tableView.contentInset.top)) { // footer完全出现，并且是往上拖拽
        [self footerBeginRefreshing];
    }
}


#pragma mark - 数据处理
/**
 *  发送请求给服务器，下拉刷新数据
 */
- (void)loadNewTopics
{
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppShopDynamic" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOShopTrendItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        [self.footer setHidden: (_dataArr.count<=0)];
        
        [self.tableView reloadData];
        // 结束刷新
        [self headerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 结束刷新
        [self headerEndRefreshing];
    }];
}

/**
 *  发送请求给服务器，上拉加载更多数据
 */
- (void)loadMoreTopics
{
    
    NSLog(@"more");
    
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    MCOShopTrendItem *item = self.dataArr[self.dataArr.count-1];
    NSDictionary *dict = @{@"lastime":item.uptime};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppShopDynamic" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        NSArray *dataNew = [MCOShopTrendItem mj_objectArrayWithKeyValuesArray:dictarr];
        if(dataNew.count>0)
        {
            [self.dataArr addObjectsFromArray:dataNew];
            [self.tableView reloadData];
            // 结束刷新
            [self footerEndRefreshing];
        }
        else
        {
            self.footerLabel.text = @"没有更多内容了~";
            self.footerRefreshing = NO;
        }
       
      
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 结束刷新
        [self footerEndRefreshing];
    }];
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

#pragma mark - footer刷新
- (void)footerBeginRefreshing
{
    // 如果正在上拉刷新，直接返回
    if (self.isFooterRefreshing) return;
    
    // 进入刷新状态
    self.footerRefreshing = YES;
    self.footerLabel.text = @"正在加载更多数据...";
//    self.footerLabel.backgroundColor = [UIColor blueColor];
    
    // 发送请求给服务器，上拉加载更多数据
    [self loadMoreTopics];
}

- (void)footerEndRefreshing
{
    self.footerRefreshing = NO;
    self.footerLabel.text = @"上拉可以加载更多";
//    self.footerLabel.backgroundColor = [UIColor redColor];
}

@end
