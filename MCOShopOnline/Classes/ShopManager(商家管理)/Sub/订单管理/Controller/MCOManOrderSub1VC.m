//
//  MCOManOrderSub1VC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/15.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOManOrderSub1VC.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOShopOrderCell1.h"
#import "MCOShopOrder.h"
#import "MCOOrderAddressVC.h"
#import "MBProgressHUD+XMG.h"
#import "MCOSendGoodVC.h"
static NSString * const ID = @"shopordcell1";
@interface MCOManOrderSub1VC ()
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property(nonatomic,strong)NSMutableArray *dataArr;
/** 当前最后一条数据的描述信息，专门用来加载下一页数据 */
@property (nonatomic, copy) NSString *maxtime;
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

@implementation MCOManOrderSub1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 10;
    
    //设置刷新
    [self setupRefresh];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOShopOrderCell1" bundle:nil] forCellReuseIdentifier:ID];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendGood:) name:@"sendGood" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewAddr:) name:@"viewAddr" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerBeginRefreshing) name:@"fresh" object:nil];
}

//查看收货地址
-(void)viewAddr:(NSNotification *)noti
{
    MCOShopOrder *order = noti.userInfo[@"order"];
    MCOOrderAddressVC *vc = [[MCOOrderAddressVC alloc] init];
    vc.order = order;
    [self.navigationController pushViewController:vc animated:YES];
}

//发货
-(void)sendGood:(NSNotification *)noti
{
    
    MCOShopOrder *order = noti.userInfo[@"order"];
    //创建控制器
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择派送方式？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //创建按钮
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"快递派送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MCOSendGoodVC *vc = [[MCOSendGoodVC alloc] init];
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"商家派送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uploadOrderByShopSend:order];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //添加按钮
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [alertVC addAction:action3];
    //显示弹框
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

//商家派送
-(void)uploadOrderByShopSend:(MCOShopOrder *)order
{
    [MBProgressHUD showMessage:@"订单更新中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict =@{@"ord_user":order.user_phone,@"ord_id":order.ord_id,@"ord_status":@"9"};
    [manager POST:@"http://106.14.145.208/ShopMall/UploadOrderStatus" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"订单更新失败，请稍后再试！"];
            
        }
        else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"订单已更新"];
            
            [self headerBeginRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"订单更新失败，请稍后再试！"];
    }];
}

- (void)setupRefresh
{
    
    // header
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, - 55, self.tableView.frame.size.width, 50);
    self.header = header;
    [self.tableView addSubview:header];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = header.bounds;
    headerLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCOShopOrderCell1 *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.order =_dataArr[indexPath.section];
    cell.index = 0;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalHeight = 80;
    MCOShopOrder *ord = _dataArr[indexPath.section];
    totalHeight += (85 * ord.ord_products.count);
    return totalHeight;
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
    NSDictionary *dict =@{@"que":@"0"};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackShopOrders" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOShopOrder mj_objectArrayWithKeyValuesArray:dictarr];
        
        [self.footer setHidden: (_dataArr.count<=0)];
        
        [self.tableView reloadData];
        
        [self headerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self headerEndRefreshing];
    }];
}

/**
 *  发送请求给服务器，上拉加载更多数据
 */
- (void)loadMoreTopics
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    MCOShopOrder *lastorder = _dataArr[_dataArr.count - 1];
    NSDictionary *dict =@{@"que":@"0",@"lastime":lastorder.ord_time};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackShopOrders" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        NSArray *dataNew = [MCOShopOrder mj_objectArrayWithKeyValuesArray:dictarr];
        
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
