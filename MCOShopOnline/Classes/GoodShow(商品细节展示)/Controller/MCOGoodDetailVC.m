//
//  MCOGoodDetailVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodDetailVC.h"
#import "MCOGoodTableViewCell.h"
#import "MCOScrollView.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "MCOGoodDetailItem.h"
#import "MCOXCPhotoCell.h"
#import "MCOGoodSubViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "MCOGoodSubChooseVC.h"
#import "UIImageView+WebCache.h"
#import "ViewController.h"
#import "MCOSelfOrder.h"
#import "MCOSelecrtAddrfViewController.h"
#import "MCOCartPayViewController.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
#import <JMessage/JMessage.h>
#import "JCHATConversationViewController.h"
static NSString * const ID = @"cellgood";
static NSString * const CollectID = @"cellphoto";
static NSInteger const cols = 1;
static CGFloat const margin = 0;
#define MCOScreenW [UIScreen mainScreen].bounds.size.width
#define MCOScreenH [UIScreen mainScreen].bounds.size.height
#define itemW (MCOScreenW - (cols - 1) * margin) / cols
#define itemH 260
@interface MCOGoodDetailVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property (nonatomic,strong)NSArray *arrData;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *xcphotoArr;
@property (nonatomic,strong)MCOGoodTableViewCell *photocell;
@property (nonatomic,strong)MCOScrollView *scrol;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCOGoodDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    

    //设置刷新
    [self setupRefresh];

    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOGoodTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
    
    self.tableView.sectionHeaderHeight = 0.1;
    self.tableView.sectionFooterHeight = 10;
    self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

    MCOGoodTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MCOGoodTableViewCell" owner:nil options:nil] firstObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 360);
    _photocell = cell;
    MCOScrollView *scrol = [MCOScrollView scrollView];
    scrol.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height*0.7);
    [cell addSubview:scrol];
    _scrol = scrol;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyNow:) name:@"buyNotif" object:nil];
}

//发货
-(void)buyNow:(NSNotification *)noti
{
    MCOSelfOrder *order = noti.userInfo[@"order"];
    NSString *type = noti.userInfo[@"type"];
    if([type isEqualToString:@"8"])//自提
    {
        MCOCartPayViewController *vc = [[MCOCartPayViewController alloc] init];
        vc.order =order;
        vc.taketype = @"8";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else//派送
    {
        MCOSelecrtAddrfViewController *vc = [[MCOSelecrtAddrfViewController alloc] init];
        vc.order =order;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)showChooseVC {
    MCOGoodSubChooseVC *subvc =[[MCOGoodSubChooseVC alloc] init];
    subvc.item = self.arrData[0];
    [self presentSemiViewController:subvc withOptions:@{KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                        KNSemiModalOptionKeys.animationDuration : @(0.6),
                                                        KNSemiModalOptionKeys.shadowOpacity     : @(0.8)
                                                        }];
}

- (IBAction)buyNowClick {
    MCOGoodSubChooseVC *subvc =[[MCOGoodSubChooseVC alloc] init];
    subvc.item = self.arrData[0];
    subvc.hideInsertCart = @"yes";
    [self presentSemiViewController:subvc withOptions:@{KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                        KNSemiModalOptionKeys.animationDuration : @(0.6),
                                                        KNSemiModalOptionKeys.shadowOpacity     : @(0.8)
                                                        }];
}


#pragma mark - 设置刷新控件
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
    UICollectionView *collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, itemH * _xcphotoArr.count+30) collectionViewLayout:layout];
    _collectionView = collectView;
    collectView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = collectView;

    //设置代理
    collectView.dataSource = self;
    collectView.delegate = self;
    //设置不能滚动
    collectView.scrollEnabled = NO;
    
    // 注册cell
    [collectView registerNib:[UINib nibWithNibName:@"MCOXCPhotoCell" bundle:nil] forCellWithReuseIdentifier:CollectID];
    
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.xcphotoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 从缓存池取
    MCOXCPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectID forIndexPath:indexPath];
    cell.url = self.xcphotoArr[indexPath.row];
    
    return cell;
}

-(void)setGoodID:(NSString *)GoodID
{
    _GoodID = GoodID;
}


#pragma mark -tbaleview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)return 1;
    else return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        //取出模型数据
        MCOGoodDetailItem *item = self.arrData[0];
        _photocell.item = item;
        NSString *photos = item.pro_photo;
        //去除最后一个分号
        photos = [photos substringToIndex:[photos length] - 1];
        NSArray *photoArr = [photos componentsSeparatedByString:@";"];
        _scrol.imageNames = photoArr;
        return _photocell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"选择 尺码颜色分类";
                break;
            case 1:
                cell.textLabel.text = @"商品参数";
                break;

        }
        return cell;
    }
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==0) return 360;
    else return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if(indexPath.section == 1)
   {
       switch (indexPath.row) {
           case 0:
           {
               MCOGoodSubChooseVC *subvc =[[MCOGoodSubChooseVC alloc] init];
               subvc.item = self.arrData[0];
               [self presentSemiViewController:subvc withOptions:@{KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                   KNSemiModalOptionKeys.animationDuration : @(0.6),
                                                                   KNSemiModalOptionKeys.shadowOpacity     : @(0.8)
                                                                   }];
             
           }
               
               break;
           case 1:
           {
               MCOGoodSubViewController *subvc =[[MCOGoodSubViewController alloc] init];
               subvc.item = self.arrData[0];
               [self presentSemiViewController:subvc withOptions:@{KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                   KNSemiModalOptionKeys.animationDuration : @(0.6),
                                                                   KNSemiModalOptionKeys.shadowOpacity     : @(0.8)
                                                                   }];
           }
               break;
       }
   }
}

//界面即将消失时，取消请求任务
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark - 代理方法
/**
 *  用户松开scrollView时调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = - (self.tableView.contentInset.top +50);
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
    } else {
        self.headerLabel.text = @"下拉可以刷新";
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
    NSDictionary *dict = @{@"pro_id":_GoodID};
    
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppGoodDetails" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#pragma mark -处理数据
        NSArray *dictarr = responseObject;
        
        _arrData = [MCOGoodDetailItem mj_objectArrayWithKeyValuesArray:dictarr];
        
        //处理宣传图片数据
        MCOGoodDetailItem *item = _arrData[0];
        NSString *xc = item.pro_describephoto;
        //去除最后一个分号
        xc = [xc substringToIndex:[xc length] - 1];
        _xcphotoArr = [xc componentsSeparatedByString:@";"];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        UIImageView *topview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [view addSubview:topview];
        //        topview.frame = CGRectMake(0, 0, 40, 40);
        topview.backgroundColor = [UIColor redColor];
        topview.contentMode = UIViewContentModeScaleToFill;
        //设置圆角
        topview.layer.cornerRadius = 20;
        topview.layer.masksToBounds = YES;
        topview.clipsToBounds = YES;
        self.navigationItem.titleView = view;
        [topview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://106.14.145.208%@",[item.pro_photo componentsSeparatedByString:@";"][0]]]];
       
        // 刷新table
        [self.tableView reloadData];
        // 设置tableView底部视图
        [self setupFootView];
        
        [self headerEndRefreshing];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self headerEndRefreshing];
    }];
}
- (IBAction)chatClick {
//    UIStoryboard *storyboardcart = [UIStoryboard storyboardWithName:NSStringFromClass([ViewController class]) bundle:nil];
//    ViewController *vc = [storyboardcart instantiateInitialViewController];
//    [self.navigationController pushViewController:vc animated:YES];
    [MBProgressHUD showMessage:@"正在联线..."];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    [mgr POST:@"http://106.14.145.208:80/ShopMall/BackShopTalkMaster" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD showError:@"网络错误，请重试！"];
            
        }
        else
        {
            [JMSGConversation createSingleConversationWithUsername:resp completionHandler:^(id resultObject, NSError *error) {
                if (!error) {
                    //创建单聊会话成功， resultObject为创建的会话
                    JCHATConversationViewController *sendMessageCtl =[[JCHATConversationViewController alloc] init];
                    sendMessageCtl.hidesBottomBarWhenPushed = YES;
                    sendMessageCtl.superViewController = self;
                    JMSGConversation *conversation = resultObject;
                    sendMessageCtl.conversation = conversation;
                    [self.navigationController pushViewController:sendMessageCtl animated:YES];
                    
                   
                } else {
                    //创建单聊会话失败
                    [MBProgressHUD showError:@"商家忙，请稍后再试！"];
                }
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误，请重试！"];
    }];

}



@end
