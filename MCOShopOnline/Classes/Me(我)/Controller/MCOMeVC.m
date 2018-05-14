//
//  MCOMeVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOMeVC.h"
#import "UIBarButtonItem+Item.h"
#import "MCOSettingTableViewController.h"
#import "MCOSquareCell.h"
#import "MCOSquareItem.h"
#import "MCOWebViewController.h"
#import "MCOShopManagerTabVC.h"
#import "XMGLoginRegisterViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "MCOSelfOrdersVC.h"
#import "MCOTGViewController.h"
#import "MCOIntegralViewController.h"
static NSString * const ID = @"cell";
static NSInteger const cols = 4;
static CGFloat const margin = 1;
#define MCOScreenW [UIScreen mainScreen].bounds.size.width
#define MCOScreenH [UIScreen mainScreen].bounds.size.height
#define itemWH (MCOScreenW - (cols - 1) * margin) / cols
#define MCOIsAutoLogin @"isAutoLogin"

@interface MCOMeVC ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *squareItems;
@property (nonatomic, weak) UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIButton *jifenBtn;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIButton *redjfBtn;
/** 下拉刷新控件 */
@property (nonatomic, weak) UIView *header;
/** 下拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *headerLabel;
/** 下拉刷新控件是否正在刷新 */
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;
@end

@implementation MCOMeVC

-(NSMutableArray *)squareItems
{
    if(_squareItems == nil)
    {
        _squareItems = [NSMutableArray array];
    }
    return _squareItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置圆角
    self.iconView.layer.cornerRadius = 40;
    self.iconView.layer.masksToBounds = YES;
    
    // 设置导航条
    [self setupNavBar];
    
    // 设置tableView底部视图
    [self setupFootView];
    
    // 加载数据
    [self loadData];
    //设置刷新
    [self setupRefresh];
    
    // 处理cell间距,默认tableView分组样式,有额外头部和尾部间距
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 10;
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    [self userAutoLogin];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearInfo) name:@"quitLog" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAutoLogin) name:@"logSucuess" object:nil];
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
#pragma mark - 下拉刷新数据处理
/**
 *  发送请求给服务器，下拉刷新数据
 */
- (void)loadNewTopics
{
    
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
//    _mgr = mgr;
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"phone_num":[defaults objectForKey:@"user_phone"]};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackUserInfo" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD showError:@"刷新失败，请重试！"];
           
        }
        else
        {
            NSArray *arrsp = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSDictionary *dict = arrsp[0];
            [defaults setObject:dict[@"user_jifen"] forKey:@"user_jifen"];
            [defaults setObject:dict[@"user_redjf"] forKey:@"user_redjf"];
            if(![dict[@"user_name"] isKindOfClass:[NSNull class]])
            {
                [defaults setObject:dict[@"user_name"] forKey:@"user_name"];
            }
            else
            {
                [defaults setObject:@"" forKey:@"user_name"];
            }
            if(![dict[@"user_touxiang"] isKindOfClass:[NSNull class]])
            {
                [defaults setObject:dict[@"user_touxiang"] forKey:@"user_touxiang"];
            }
            else
            {
                [defaults setObject:@"" forKey:@"user_touxiang"];
            }
            //立马写入到文件
            [defaults synchronize];
            
            [self userAutoLogin];
        }
        
        [self headerEndRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showError:@"刷新失败，请重试！"];
        [self headerEndRefreshing];
    }];
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

#pragma mark -积分
- (IBAction)jfClick {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])
    {
        //没有登录跳转到登录注册界面
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        
    }
    else
    {
        MCOIntegralViewController *vc = [[MCOIntegralViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)clearInfo
{
    [self.jifenBtn setTitle:@"0" forState:UIControlStateNormal];
    [self.redjfBtn setTitle:@"0" forState:UIControlStateNormal];
    [self.nameBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
    [self.nameBtn setUserInteractionEnabled:YES];
    self.iconView.image = [UIImage imageNamed:@"defaultUserIcon"];
}


#pragma mark -tableview
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 && indexPath.row ==1)//我的订单
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(![defaults boolForKey:MCOIsAutoLogin])
        {
            //没有登录跳转到登录注册界面
            XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
            [self presentViewController:vc animated:YES completion:nil];
            
        }
        else
        {
            MCOSelfOrdersVC *vc = [[MCOSelfOrdersVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
       
    }
}

#pragma mark - 用户自动登录
-(void)userAutoLogin
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:MCOIsAutoLogin])
    {
        NSString *name = [defaults objectForKey:@"user_name"];
        if(name.length==0) [self.nameBtn setTitle:@"未设置" forState:UIControlStateNormal];
        else [self.nameBtn setTitle:name forState:UIControlStateNormal];
        
        //设置不可点击
        [self.nameBtn setUserInteractionEnabled:NO];
        [self.jifenBtn setTitle:[defaults objectForKey:@"user_jifen"] forState:UIControlStateNormal];
        [self.redjfBtn setTitle:[defaults objectForKey:@"user_redjf"] forState:UIControlStateNormal];
        NSString *photo = [defaults objectForKey:@"user_touxiang"];
        if(photo.length!=0)
        {
            NSString *urlStr = [NSString stringWithFormat:@"http://106.14.145.208:80%@",[defaults objectForKey:@"user_touxiang"]];
            NSURL *url = [NSURL URLWithString:urlStr];
            [self.iconView sd_setImageWithURL:url];
        }
    }
    
}

- (void)setupNavBar
{
    // 左边按钮
    // 把UIButton包装成UIBarButtonItem.就导致按钮点击区域扩大
    
    // 设置
    UIBarButtonItem *settingItem =  [UIBarButtonItem itemWithimage:[UIImage imageNamed:@"mine-setting-icon"] highImage:[UIImage imageNamed:@"mine-setting-icon-click"] target:self action:@selector(setting)];
    UIBarButtonItem *settingItem2 = [[UIBarButtonItem alloc] initWithTitle:@"推广" style:UIBarButtonItemStylePlain target:self action:@selector(tgview)];
    
    self.navigationItem.leftBarButtonItem = settingItem2;
    self.navigationItem.rightBarButtonItem = settingItem;
    
    // titleView
    self.navigationItem.title = @"我的";
    
}

-(void)tgview
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])
    {
        //没有登录跳转到登录注册界面
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    MCOTGViewController *vc = [[MCOTGViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loginRegisterClick {
    XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}



#pragma mark - 加载数据
- (void)loadData
{
    MCOSquareItem *item1 = [[MCOSquareItem alloc] init];
    item1.name = @"吉盾科技";
    item1.icon = [UIImage imageNamed:@"navigationButtonRandom"];
    item1.url = @"http://www.jidunkeji.com/";
    MCOSquareItem *item2 = [[MCOSquareItem alloc] init];
    item2.name = @"商家管理";
    item2.icon = [UIImage imageNamed:@"nav_coin_icon"];
    MCOSquareItem *item3 = [[MCOSquareItem alloc] init];
    item3.name = @"我要开店";
    item3.icon = [UIImage imageNamed:@"friendsRecommentIcon"];
    
    [self.squareItems addObject:item2];
    [self.squareItems addObject:item3];
    [self.squareItems addObject:item1];
    
    // 处理数据
    [self resloveData];
    
    // 设置collectionView 计算collectionView高度 = rows * itemWH
    // Rows = (count - 1) / cols + 1  3 cols4
    NSInteger count = _squareItems.count;
    NSInteger rows = (count - 1) / cols + 1;
    // 设置collectioView高度
    CGRect frame = self.collectionView.frame;
    frame.size.height = rows * itemWH;
    self.collectionView.frame =frame;
    // 设置tableView滚动范围:自己计算
    self.tableView.tableFooterView = self.collectionView;
    // 刷新表格
    [self.collectionView reloadData];
    
}

#pragma mark - 处理请求完成数据
- (void)resloveData
{
    NSInteger count = self.squareItems.count;
    NSInteger exter = count % cols;
    if (exter) {
        exter = cols - exter;
        for (int i = 0; i < exter; i++) {
            MCOSquareItem *item = [[MCOSquareItem alloc] init];
            [self.squareItems addObject:item];
        }
    }
    
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
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    //创建uicollectionview
    UICollectionView *collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 300) collectionViewLayout:layout];
    _collectionView = collectView;
    collectView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = collectView;
    
    //设置代理
    collectView.dataSource = self;
    collectView.delegate = self;
    //设置不能滚动
    collectView.scrollEnabled = NO;
    
    // 注册cell
    [collectView registerNib:[UINib nibWithNibName:@"MCOSquareCell" bundle:nil] forCellWithReuseIdentifier:ID];
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 跳转界面 push 展示网页
    /*
     1.Safari openURL :自带很多功能(进度条,刷新,前进,倒退等等功能),必须要跳出当前应用
     2.UIWebView (没有功能) ,在当前应用打开网页,并且有safari,自己实现,UIWebView不能实现进度条
     3.SFSafariViewController:专门用来展示网页 需求:即想要在当前应用展示网页,又想要safari功能 iOS9才能使用
     3.1 导入#import <SafariServices/SafariServices.h>
     
     4.WKWebView:iOS8 (UIWebView升级版本,添加功能 1.监听进度 2.缓存)
     4.1 导入#import <WebKit/WebKit.h>
     
     */
    // 创建网页控制器
//    XMGSquareItem *item = self.squareItems[indexPath.row];
//    if (![item.url containsString:@"http"]) return;
//    

    switch (indexPath.row) {
        case 0:
        {
            //先检验是否时商家账户
            [self judgeIsMaster];
            
        }
            break;
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"开店" message:@"请联系***********" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
            
            [alert show];
        }
            break;
        case 2:
        {
                MCOWebViewController *webVc = [[MCOWebViewController alloc] init];
                MCOSquareItem *item = self.squareItems[2];
                webVc.url = [NSURL URLWithString: item.url];
                [self.navigationController pushViewController:webVc animated:YES];
        }
            break;
    }
    
}

//检验是否是店主
-(void)judgeIsMaster
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])//没有登录就添砖
    {
        //没有登录跳转到登录注册界面
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    //http://106.14.145.208/ShopMall/JudgeAppShopManager
    [MBProgressHUD showMessage:@"正在验证身份..."];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *dict = @{@"mast_id":[defaults objectForKey:@"user_phone"]};
    [mgr POST:@"http://106.14.145.208/ShopMall/JudgeAppShopManager" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD showError:@"网络错误，请重试！"];
        }
        else if([resp isEqualToString:@"1"])
        {
            [MBProgressHUD showSuccess:@"验证成功"];
            //如果是
            UIStoryboard *storyboardme = [UIStoryboard storyboardWithName:NSStringFromClass([MCOShopManagerTabVC class]) bundle:nil];
            //加载箭头指向控制器
            MCOShopManagerTabVC *vc = [storyboardme instantiateInitialViewController];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [MBProgressHUD showError:@"抱歉，您尚未是店主！"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误"];
    }];
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.squareItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 从缓存池取
    MCOSquareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];

    cell.item = self.squareItems[indexPath.row];
    return cell;
}

- (void)setting
{
    
    // 跳转到设置界面
    MCOSettingTableViewController *settingVc = [[MCOSettingTableViewController alloc] init];
    // 必须要在跳转之前设置
    settingVc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:settingVc animated:YES];
    
    
}


@end
