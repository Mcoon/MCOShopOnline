//
//  MCOCartVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOCartVC.h"
#import "MCOCartCell.h"
#import "MCOCartItem.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "XMGLoginRegisterViewController.h"
#import "MCOGoodDetailVC.h"
#define MCOIsAutoLogin @"isAutoLogin"
static NSString * const ID = @"cartcell";
@interface MCOCartVC ()
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCOCartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];

    //设置刷新控件
    [self setupRefresh];
    // 让header自动进入刷新
    [self headerBeginRefreshing];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOCartCell" bundle:nil] forCellReuseIdentifier:ID];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    

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

#pragma mark - 判断是否登录
-(void)isLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])
    {
        //没有登录跳转到登录注册界面
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:^{
                        [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    else
    {
        //登录请求数据
        [self requestDataWithPoneNum:[defaults objectForKey:@"user_phone"]];
    }
}

-(void)requestDataWithPoneNum:(NSString *)phoneNum
{
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict =@{@"pro_id":phoneNum};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppUserCart" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOCartItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

- (void)setupNavBar
{
    self.navigationItem.title = @"购物车";
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCOCartCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.item = _dataArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - UITableViewDelegate
/**
 *  只要实现这个方法,就拥有左滑删除功能
 *  点击左滑出现的Delete按钮 会调用这个
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //取出数据
    MCOCartItem *item = self.dataArr[indexPath.row];
    //请求删除数据库信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"pro_id":[defaults objectForKey:@"user_phone"],@"good_id":item.pro_id,@"good_size":item.pro_size,@"good_color":item.pro_color};
    [_mgr POST:@"http://106.14.145.208/ShopMall/DeleteCartAGood" parameters:dict progress:nil success:nil failure:nil];
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

/**
 *  修改默认Delete按钮的文字
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取出数据
    MCOCartItem *item = self.dataArr[indexPath.row];
    UIStoryboard *storyboardme = [UIStoryboard storyboardWithName:NSStringFromClass([MCOGoodDetailVC class]) bundle:nil];
    
    //加载箭头指向控制器
    MCOGoodDetailVC *vc = [storyboardme instantiateInitialViewController];
    vc.GoodID = item.pro_id;
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
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict =@{@"pro_id":[defaults objectForKey:@"user_phone"]};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppUserCart" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOCartItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        
        [self.tableView reloadData];
        // 结束刷新
        [self headerEndRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 结束刷新
        [self headerEndRefreshing];
    }];
}

@end
