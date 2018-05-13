//
//  MCOQueryTableViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOQueryTableViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOShopGoodItem.h"
#import "MCOQueryCell.h"
#import "MCOGoodDetailVC.h"
static NSString * const ID = @"cell";
@interface MCOQueryTableViewController ()<UISearchBarDelegate>
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,weak)UISearchBar *searchBar;
@end

@implementation MCOQueryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *searchView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 35)];
    UISearchBar *bar =  [[UISearchBar alloc] initWithFrame:searchView.frame];
    bar.placeholder = @"换个宝贝搜搜～";
    bar.text = _key;
    bar.delegate = self;
    //设置placeholder颜色字体
    UITextField * searchField = [bar valueForKey:@"_searchField"];
    [searchField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [searchField setValue:[UIFont boldSystemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
    _searchBar = bar;
    [searchView addSubview:bar];
    self.navigationItem.titleView = searchView;
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOQueryCell" bundle:nil] forCellReuseIdentifier:ID];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

-(void)setKey:(NSString *)key
{
    _key = key;
    [self loadData];
}
#pragma  mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _key = searchBar.text;
    [self loadData];
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
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

#pragma mark - 加载数据
- (void)loadData
{
    
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict = @{@"pro_key":_key};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppQueryProduct" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *dictarr = responseObject;
        
        _dataArr = [MCOShopGoodItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        
        [self.tableView reloadData];
        //        [MBProgressHUD hideHUD];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        [MBProgressHUD hideHUD];
        //        [MBProgressHUD showError:@"网络错误"];
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
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCOQueryCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    MCOShopGoodItem *item = _dataArr[indexPath.row];
    cell.item = item;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCOShopGoodItem *item =self.dataArr[indexPath.row];
    
    UIStoryboard *storyboardme = [UIStoryboard storyboardWithName:NSStringFromClass([MCOGoodDetailVC class]) bundle:nil];
    
    //加载箭头指向控制器
    MCOGoodDetailVC *vc = [storyboardme instantiateInitialViewController];
    vc.GoodID = item.pro_id;
    [self.navigationController pushViewController:vc animated:YES];
}

//界面即将消失时，取消请求任务
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}

@end
