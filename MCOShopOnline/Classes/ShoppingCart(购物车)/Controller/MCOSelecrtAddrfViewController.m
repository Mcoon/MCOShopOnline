//
//  MCOSelecrtAddrfViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/28.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelecrtAddrfViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOUserAddrItem.h"
#import "MCOAddressCell.h"
#import "MCOAddCommonAddrVC.h"
#import "MCOCartPayViewController.h"
static NSString * const ID = @"addrtcell";
@interface MCOSelecrtAddrfViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addAddressBtn;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCOSelecrtAddrfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addAddressBtn.layer.cornerRadius = 15;
    
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    [self setupNavBar];
    //设置刷新
    [self setupRefresh];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOAddressCell" bundle:nil] forCellReuseIdentifier:ID];
    
}

#pragma  mark -设置刷新控件
- (void)setupRefresh
{
    
    // header
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, -50, self.tableView.frame.size.width, 50);
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
    
    //刷新请求数据
    [self headerBeginRefreshing];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setupNavBar
{
    self.navigationItem.title = @"选择收货地址";
    
}

#pragma mark -添加常用地址
- (IBAction)addAddress {
    MCOAddCommonAddrVC *vc = [[MCOAddCommonAddrVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCOAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.address = _dataArr[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取出数据
    MCOUserAddrItem *item = self.dataArr[indexPath.row];
    MCOCartPayViewController *vc = [[MCOCartPayViewController alloc] init];
    vc.address = item;
    vc.order = self.order;
    vc.taketype = @"0";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 代理方法
/**
 *  用户松开scrollView时调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = - (self.tableView.contentInset.top + 50);
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
    CGFloat offsetY = - (self.tableView.contentInset.top + 50);
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
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"ord_phone":[defaults objectForKey:@"user_phone"]};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppUserCommonAddr" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOUserAddrItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        
        [self.tableView reloadData];
        
        [self headerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self headerEndRefreshing];
    }];
}
@end
