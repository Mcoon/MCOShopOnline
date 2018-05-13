//
//  MCORefRecordVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCORefRecordVC.h"
#import "AFNetworking.h"
#import "MCORefCell.h"
#import "MJExtension.h"
#import "MCORef.h"
static NSString * const ID = @"refcell";
@interface MCORefRecordVC ()
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCORefRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    //设置刷新
    [self setupRefresh];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCORefCell" bundle:nil] forCellReuseIdentifier:ID];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.clipsToBounds = YES;
}

- (void)setupNavBar
{
    self.navigationItem.title = @"提现记录";
    
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
    
    // 让header自动进入刷新
    [self headerBeginRefreshing];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCORefCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.type = self.status;
    cell.item = self.dataArr[indexPath.row];
    cell.clipsToBounds = YES;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_status isEqualToString:@"0"])
    {
        return 120;
    }
    else
    {
        MCORef *item = _dataArr[indexPath.row];
        if([item.ref_status isEqualToString:@"1"])
        {
            return 120;
        }
        else
        {
             return 166;
        }
       
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
    
    if([self.status isEqualToString:@"0"])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict  = @{@"user_phone":[defaults objectForKey:@"user_phone"]};
        [mgr POST:@"http://106.14.145.208/ShopMall/BackUserReflect" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSArray *dictarr = responseObject;
            
            _dataArr = [MCORef mj_objectArrayWithKeyValuesArray:dictarr];
            
            [self.tableView reloadData];
            
            // 结束刷新
            [self headerEndRefreshing];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // 结束刷新
            [self headerEndRefreshing];
        }];
    }
    else
    {
        [mgr POST:@"http://106.14.145.208/ShopMall/BackUserReflect" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSArray *dictarr = responseObject;
            
            _dataArr = [MCORef mj_objectArrayWithKeyValuesArray:dictarr];
            
            [self.tableView reloadData];
            
            // 结束刷新
            [self headerEndRefreshing];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // 结束刷新
            [self headerEndRefreshing];
        }];
    }
   
}

@end
