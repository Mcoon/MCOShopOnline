//
//  MCOCartViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/9.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOCartViewController.h"
#import "MCOCartCell.h"
#import "MCOCartItem.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "XMGLoginRegisterViewController.h"
#import "MBProgressHUD+XMG.h"
#import "MCOGoodDetailVC.h"
#import "MCOSelfOrder.h"
#import "MCOSelecrtAddrfViewController.h"
#import "MCOCartPayViewController.h"

#define MCOIsAutoLogin @"isAutoLogin"
static NSString * const ID = @"cartcell";
@interface MCOCartViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCOCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    
    [self setupNavBar];
    //设置刷新
    [self setupRefresh];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOCartCell" bundle:nil] forCellReuseIdentifier:ID];
    
    self.tableView.tableFooterView = [[UIView alloc] init];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //判断登录
    [self isLogin];
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
    

}

#pragma mark - 判断是否登录
-(void)isLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])
    {
        [self.tabBarController setSelectedIndex:0];
        
        //没有登录跳转到登录注册界面
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];

       
        
      
    }
    else
    {
         //刷新请求数据
        [self headerBeginRefreshing];
    }
}


- (void)setupNavBar
{
    self.navigationItem.title = @"购物车";
    
}
- (IBAction)payForMoney {
    
    if(_dataArr.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲" message:@"您的购物车空空如也，快去添加商品哦～" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择商品配送方式？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"商家派送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self payForSend];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"店铺自提" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self payForSelfTake];
        }];
        //添加按钮
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

#pragma mark -派送
-(void)payForSend
{
    MCOSelfOrder *order = [[MCOSelfOrder alloc] init];
    order.ord_products = self.dataArr;
    order.ord_money = self.totalPriceLabel.text;
    MCOSelecrtAddrfViewController *vc = [[MCOSelecrtAddrfViewController alloc] init];
    vc.order =order;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -自提付款
-(void)payForSelfTake
{
    
    MCOSelfOrder *order = [[MCOSelfOrder alloc] init];
    order.ord_products = self.dataArr;
    order.ord_money = self.totalPriceLabel.text;
    MCOCartPayViewController *vc = [[MCOCartPayViewController alloc] init];
    vc.order =order;
    vc.taketype = @"8";
    [self.navigationController pushViewController:vc animated:YES];
    
    
//    //此处跳转支付宝app付钱
//
//    //付款成功后
//    [self uploadOrd];
}

#pragma mark -上传订单信息(自提)
-(void)uploadOrd
{
    [MBProgressHUD showMessage:@"提交订单中..."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"user_phone"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (MCOCartItem *item in _dataArr) {
        NSDictionary *dict = @{@"ord_gooid":item.pro_id,@"ord_size":item.pro_size,@"ord_color":item.pro_color,@"ord_num":[NSString stringWithFormat:@"%ld",(long)item.pro_num]};
        [arr addObject:dict];
    }
    NSDictionary *dict = @{@"ord_user":phone,@"products":[arr mj_JSONString],@"money":[NSString stringWithFormat:@"%.2f",100.32],@"taketype":@"8"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"http://106.14.145.208/ShopMall/SubmitUsersOrder" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"订单发送失败,请稍后再试"];
        }
        else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"订单发送成功"];
            //刷新数据
            [self headerBeginRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"订单发送失败,请稍后再试"];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCOCartCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.item = _dataArr[indexPath.row];
    cell.row =indexPath.row;
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
    [item removeObserver:self forKeyPath:@"pro_num"];
    
    //请求删除数据库信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"pro_id":[defaults objectForKey:@"user_phone"],@"good_id":item.pro_id,@"good_size":item.pro_size,@"good_color":item.pro_color};
    [_mgr POST:@"http://106.14.145.208/ShopMall/DeleteCartAGood" parameters:dict progress:nil success:nil failure:nil];
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    [self recount];
}

//计算总额
-(void)recount
{
    float total = 0;
    for (MCOCartItem *item in self.dataArr) {
        float discount = [item.pro_discount floatValue];
        float nowPrice = [item.pro_price floatValue] * discount;
        total += nowPrice * item.pro_num;
    }
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%.2f",total];
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
    //去除kvo
    for(MCOCartItem *item in self.dataArr)
    {
        [item removeObserver:self forKeyPath:@"pro_num"];
    }
    
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"pro_id":[defaults objectForKey:@"user_phone"]};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppUserCart" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOCartItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        [self addKvoObserver];
        [self.tableView reloadData];
        
        [self headerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self headerEndRefreshing];
    }];
}

//添加kvo
-(void)addKvoObserver
{
    float total = 0;
    for (MCOCartItem *item in self.dataArr) {
        float discount = [item.pro_discount floatValue];
        float nowPrice = [item.pro_price floatValue] * discount;
        total += nowPrice * item.pro_num;
        [item addObserver:self forKeyPath:@"pro_num" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
    }
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%.2f",total];
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(MCOCartItem *)item change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    // NSKeyValueChangeNewKey == @"new"
    int new = [change[NSKeyValueChangeNewKey] intValue];
    // NSKeyValueChangeOldKey == @"old"
    int old = [change[NSKeyValueChangeOldKey] intValue];
    
    float discount = [item.pro_discount floatValue];
    float nowPrice = [item.pro_price floatValue] * discount;
    
    if (new > old) { // 数量增加,点击加号
        float totalprice = self.totalPriceLabel.text.intValue + nowPrice;
        self.totalPriceLabel.text = [NSString stringWithFormat:@"%.2f",totalprice];
    } else { // 数量减少,点击减号
        float totalprice = self.totalPriceLabel.text.intValue - nowPrice;
        self.totalPriceLabel.text = [NSString stringWithFormat:@"%.2f",totalprice];
    }
}
@end
