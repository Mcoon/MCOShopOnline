//
//  MCOQueryTableViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOQueryEditTableViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOShopGoodItem.h"
#import "MCOQueryCell.h"
#import "MCOGoodDetailVC.h"
#import "MCOGoodEditVC.h"
static NSString * const ID = @"cell";
@interface MCOQueryEditTableViewController ()<UISearchBarDelegate>
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,weak)UISearchBar *searchBar;
@end

@implementation MCOQueryEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

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

#pragma mark -左滑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑"handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        MCOGoodEditVC *vc = [[MCOGoodEditVC alloc] init];
        MCOGoodDetailItem *item = self.dataArr[indexPath.row];
        vc.good = item;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    action1.backgroundColor = [UIColor orangeColor];
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定要删除商品吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteProduct:indexPath];
        }];
        //添加按钮
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }];
    action2.backgroundColor = [UIColor redColor];
    
    //此处UITableViewRowAction对象放入的顺序决定了对应按钮在cell中的顺序
    return@[action1,action2];
}

-(void)deleteProduct:(NSIndexPath *)indexPath
{
    
    MCOShopGoodItem *item =self.dataArr[indexPath.row];
    
    //支持text/html
    self.mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    self.mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict = @{@"good_id":item.pro_id};
    [self.mgr POST:@"http://106.14.145.208/ShopMall/DeleteProductById" parameters:dict progress:nil success:nil failure:nil];
    
    [self.dataArr removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

@end
