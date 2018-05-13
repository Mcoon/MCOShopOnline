//
//  MCOShopSubTableViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/3.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOShopSubTableViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "MCOQueryTableViewController.h"

@interface MCOShopSubTableViewController ()

@property(strong,nonatomic)NSArray *dataArr;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;

@end

@implementation MCOShopSubTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    
    [self loadData];
    
    [MBProgressHUD showMessage:@"正在加载ing..."];
    
   self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setupNavBar
{
    
    // titleView
    self.navigationItem.title = @"分类";
    
}


#pragma mark - 请求数据
-(void)loadData
{
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppClassify" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //去除最后一个逗号
        resp = [resp substringToIndex:resp.length-1];
        
        _dataArr = [resp componentsSeparatedByString:@","];
       
        [self.tableView reloadData];
        
        [MBProgressHUD hideHUD];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误"];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;  
    return cell;
}

//界面即将消失时，取消请求任务
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hideHUD];
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *key = self.dataArr[indexPath.row];
    MCOQueryTableViewController *vc =[[MCOQueryTableViewController alloc] init];
    vc.key =key;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
