//
//  MCOGoodSubChooseVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodSubChooseVC.h"
#import "UIViewController+KNSemiModal.h"
#import "MCOGoodSelectCell.h"
#import "MCOGoodDetailItem.h"
#import "MCOGoodNumCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "XMGLoginRegisterViewController.h"
#import "MCOSelfOrder.h"
#import "MCOCartItem.h"
#define MCOIsAutoLogin @"isAutoLogin"
static NSString * const ID = @"cell";
static NSString * const IDI = @"numcell";
@interface MCOGoodSubChooseVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic) MCOGoodSelectCell *sizecell;
@property (weak,nonatomic) MCOGoodSelectCell *colorcell;
@property (weak,nonatomic) MCOGoodNumCell *numcell;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property (weak, nonatomic) IBOutlet UIButton *insertCartBtn;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UIView *btnView;

@end

@implementation MCOGoodSubChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if(self.hideInsertCart.length!=0)
    {
        self.insertCartBtn.hidden = YES;
    }
    
    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 400);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //指定位置设置圆角
    /*
     * UIRectCornerTopLeft
     * UIRectCornerTopRight
     * UIRectCornerBottomLeft
     * UIRectCornerBottomRight
     * UIRectCornerAllCorners
     */
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOGoodSelectCell" bundle:nil] forCellReuseIdentifier:ID];
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOGoodNumCell" bundle:nil] forCellReuseIdentifier:IDI];
}


-(void)setItem:(MCOGoodDetailItem *)item
{
    _item = item;
    [self.tableView reloadData];
}

#pragma mark - 加入购物车
- (IBAction)insertCart {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])//未登录
    {
        [self dismissSemiModalViewWithCompletion:nil];
        
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    
        return;
    }

    if([_colorcell backSelectedValue]==nil)
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择宝贝颜色" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        //添加按钮
        [alertVC addAction:action1];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else if([_sizecell backSelectedValue]==nil)
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择宝贝尺码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        //添加按钮
        [alertVC addAction:action1];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else if([_numcell backSelectedNum]==0)
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择宝贝数量" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        //添加按钮
        [alertVC addAction:action1];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else
    {
        [MBProgressHUD showMessage:@"正在加入购物车"];
        // 1.创建请求会话管理者
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        _mgr = mgr;
        
        //支持text/html
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        //resp内容为非json处理方法
        mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
      
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        if(![defaults boolForKey:MCOIsAutoLogin])//未登录
//        {
//            XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
//            [self presentViewController:vc animated:YES completion:nil];
//        }
//        else
//        {
            NSString *phone = [defaults objectForKey:@"user_phone"];
            /*
             手机号：pro_id
             商品id：good_id
             商品数量：good_num
             */
            NSDictionary *dict = @{@"pro_id":phone,@"good_id":_item.pro_id,@"good_num":[NSString stringWithFormat:@"%ld",(long)[_numcell backSelectedNum]],@"good_size":[_sizecell backSelectedValue],@"good_color":[_colorcell backSelectedValue]};
            [mgr POST:@"http://106.14.145.208:80/ShopMall/UploadUserCart" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [MBProgressHUD hideHUD];
                NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                if([resp isEqualToString:@"ok"])
                {
                    [MBProgressHUD showSuccess:@"加入成功"];
                    [self dismissSemiModalViewWithCompletion:nil];
                }
                else
                {
                    
                    [MBProgressHUD showError:@"加入失败，请重试！"];
                }
                
                
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"网络错误"];
            }];
//        }
        
        
    }
}

#pragma mark - 界面即将消失
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hideHUD];
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark - 立即购买
- (IBAction)buyNow {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:MCOIsAutoLogin])//未登录
    {
        [self dismissSemiModalViewWithCompletion:nil];
        
        XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        
        return;
    }
    
    if([_colorcell backSelectedValue]==nil)
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择宝贝颜色" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        //添加按钮
        [alertVC addAction:action1];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else if([_sizecell backSelectedValue]==nil)
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择宝贝尺码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        //添加按钮
        [alertVC addAction:action1];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else if([_numcell backSelectedNum]==0)
    {
        //创建控制器
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择宝贝数量" message:nil preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        //添加按钮
        [alertVC addAction:action1];
        //显示弹框
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else
    {
        [self dismissSemiModalView];
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
    MCOCartItem *item = [[MCOCartItem alloc] init];
    item.pro_id =self.item.pro_id;
    item.pro_size = [_sizecell backSelectedValue];
    item.pro_color = [_colorcell backSelectedValue];
    item.pro_num = [_numcell backSelectedNum];
    
    MCOSelfOrder *order = [[MCOSelfOrder alloc] init];
    
    order.ord_products = @[item];
    float discount = [self.item.pro_discount floatValue];
    float nowPrice = [self.item.pro_price floatValue] * discount;
    
    float money = item.pro_num * nowPrice;
    order.ord_money = [NSString stringWithFormat:@"%.2f",money];
    
    NSDictionary *dict = @{@"order":order,@"type":@"0"};
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buyNotif" object:nil userInfo:dict];
    
}


#pragma mark -自提付款
-(void)payForSelfTake
{
    
    MCOCartItem *item = [[MCOCartItem alloc] init];
    item.pro_id =self.item.pro_id;
    item.pro_size = [_sizecell backSelectedValue];
    item.pro_color = [_colorcell backSelectedValue];
    item.pro_num = [_numcell backSelectedNum];
    
    MCOSelfOrder *order = [[MCOSelfOrder alloc] init];
    
    order.ord_products = @[item];
    float discount = [self.item.pro_discount floatValue];
    float nowPrice = [self.item.pro_price floatValue] * discount;
    
    float money = item.pro_num * nowPrice;
    order.ord_money = [NSString stringWithFormat:@"%.2f",money];
    
    NSDictionary *dict = @{@"order":order,@"type":@"8"};
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buyNotif" object:nil userInfo:dict];
}

- (IBAction)close {
    [self dismissSemiModalViewWithCompletion:nil];
}

#pragma mark -tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row ==0 )
    {
        MCOGoodSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 100);
        cell.proityName = @"宝贝颜色";
        cell.selectValues =_item.pro_color;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _colorcell = cell;
        return cell;
    }
    else if(indexPath.row ==1 )
    {
        MCOGoodSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 100);
        cell.proityName = @"宝贝尺码";
        cell.selectValues =_item.pro_size;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _sizecell = cell;
        return cell;
    }
    else
    {
        MCOGoodNumCell *cell = [tableView dequeueReusableCellWithIdentifier:IDI];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 100);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _numcell =cell;
        return cell;
        
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

@end
