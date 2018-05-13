//
//  MCOCartPayViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/28.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOCartPayViewController.h"
#import "MCOSelfOrder.h"
#import "MCOUserAddrItem.h"
#import "AFNetworking.h"
#import "MCOCartItem.h"
#import "MJExtension.h"
#import "MBProgressHUD+XMG.h"
#import <AlipaySDK/AlipaySDK.h>
@interface MCOCartPayViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *usejfSwitch;
@property (weak, nonatomic) IBOutlet UILabel *takeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *reduceMoneyLabel;
@property(nonatomic,assign)float orginalMmoney;
@property(nonatomic,assign)NSInteger usejfNum;
@end

@implementation MCOCartPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"明细";
    
    _moneyLabel.text =_order.ord_money;
    if([_taketype isEqualToString:@"8"])
    {
        _takeTypeLabel.text = @"自提";
    }
    else
    {
        _takeTypeLabel.text = @"商家配送";
    }
    
    _orginalMmoney = _order.ord_money.floatValue;
    
    [self.usejfSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealAlipayBack:) name:@"alipayback" object:nil];
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
   if([switchButton isOn])
   {
       [self dealRedJF];
   }
    else
    {
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",self.orginalMmoney];
        self.order.ord_money = [NSString stringWithFormat:@"%.2f",self.orginalMmoney];
        self.reduceMoneyLabel.text = @" ";
        self.usejfNum = 0;
    }
    
    
}

#pragma mark - 处理红积分
-(void)dealRedJF
{
    [MBProgressHUD showMessage:@"积分查询中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"user_phone":[defaults objectForKey:@"user_phone"]};
    [manager POST:@"http://106.14.145.208/ShopMall/BackUserRedJF" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"积分查询失败，请稍后再试！"];
            self.usejfSwitch.on = NO;
        }
        else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"积分查询成功"];
            
            NSInteger ijf = resp.intValue;
            NSInteger reducemoney = ijf/100;
            if(reducemoney >= self.orginalMmoney)
            {
                self.usejfNum = self.orginalMmoney * 100;
                self.order.ord_money = [NSString stringWithFormat:@"0.01"];
                self.moneyLabel.text = self.order.ord_money;
                self.reduceMoneyLabel.text = [NSString stringWithFormat:@"已 -%.2f 元",self.orginalMmoney];
            }
            else
            {
                self.usejfNum = 100 * reducemoney;
                float lastmoney = self.orginalMmoney - reducemoney;
                self.order.ord_money = [NSString stringWithFormat:@"%.2f",lastmoney];
                self.moneyLabel.text = self.order.ord_money;
                self.reduceMoneyLabel.text = [NSString stringWithFormat:@"已 -%ld 元",reducemoney];
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"积分查询失败，请稍后再试！"];
        self.usejfSwitch.on = NO;
    }];
}

- (IBAction)paymoney {
    [MBProgressHUD showMessage:@"订单查询中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"ord_user":[defaults objectForKey:@"user_phone"],@"money":self.order.ord_money};
    [manager POST:@"http://106.14.145.208/ShopMall/BackAppAlipayOrderString" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器忙，请稍后再试！"];
        }
        else
        {
            //跳转支付宝支付
            [MBProgressHUD hideHUD];
            [MBProgressHUD showMessage:@"订单支付中..."];
            NSString *appScheme = @"mcoshoponline";
//            [[AlipaySDK defaultService] payOrder:resp fromScheme:appScheme callback:nil];
            [[AlipaySDK defaultService] payOrder:resp fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                [MBProgressHUD hideHUD];
                NSDictionary *result =resultDic;
                if([result[@"resultStatus"] isEqualToString:@"9000"])
                {
                    if([self.taketype isEqualToString:@"0"])//商家配送
                    {
                        [self pay2];
                    }
                    else//自提
                    {
                        [self pay1];
                    }
                }
                else
                {
                    [MBProgressHUD showError:[NSString stringWithFormat:@"您'%@',请重试!",result[@"memo"]]];
                }
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器忙，请稍后再试！"];
    }];
    
}

-(void)dealAlipayBack:(NSNotification  *)notifi
{
    [MBProgressHUD hideHUD];
    NSDictionary *result =notifi.userInfo;
    if([result[@"resultStatus"] isEqualToString:@"9000"])
    {
        if([self.taketype isEqualToString:@"0"])//商家配送
        {
            [self pay2];
        }
        else//自提
        {
            [self pay1];
        }
    }
    else
    {
        [MBProgressHUD showError:[NSString stringWithFormat:@"您'%@',请重试!",result[@"memo"]]];
    }
}

-(void)pay1
{
    
    [self uploadOrder1];
}

-(void)pay2
{
    //付款成功后
    [self uploadOrder2];
}

//自提方式
-(void)uploadOrder1
{
    [MBProgressHUD showMessage:@"提交订单中..."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"user_phone"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (MCOCartItem *item in self.order.ord_products) {
        NSDictionary *dict = @{@"ord_gooid":item.pro_id,@"ord_size":item.pro_size,@"ord_color":item.pro_color,@"ord_num":[NSString stringWithFormat:@"%ld",(long)item.pro_num]};
        [arr addObject:dict];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:phone forKey:@"ord_user"];
    [dict setValue:[arr mj_JSONString] forKey:@"products"];
    [dict setValue:self.order.ord_money forKey:@"money"];
    [dict setValue:@"8" forKey:@"taketype"];
    
    if([self.usejfSwitch isOn])
    {
        [dict setValue:[NSString stringWithFormat:@"%ld",self.usejfNum] forKey:@"usejf"];
    }
    
//    NSDictionary *dict = @{@"ord_user":phone,@"products":[arr mj_JSONString],@"money":self.order.ord_money,@"taketype":@"8"};
    
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
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"订单发送失败,请稍后再试"];
    }];
}
//商家配送
-(void)uploadOrder2
{
    [MBProgressHUD showMessage:@"提交订单中..."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"user_phone"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (MCOCartItem *item in self.order.ord_products) {
        NSDictionary *dict = @{@"ord_gooid":item.pro_id,@"ord_size":item.pro_size,@"ord_color":item.pro_color,@"ord_num":[NSString stringWithFormat:@"%ld",(long)item.pro_num]};
        [arr addObject:dict];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:phone forKey:@"ord_user"];
    [dict setValue:[arr mj_JSONString] forKey:@"products"];
    [dict setValue:self.order.ord_money forKey:@"money"];
    [dict setValue:@"0" forKey:@"taketype"];
    [dict setValue:self.address.rev_name forKey:@"rev_name"];
    [dict setValue:self.address.rev_phone forKey:@"rev_phone"];
    [dict setValue:self.address.rev_address forKey:@"rev_addr"];
    
    if([self.usejfSwitch isOn])
    {
        [dict setValue:[NSString stringWithFormat:@"%ld",self.usejfNum] forKey:@"usejf"];
    }
    
//    NSDictionary *dict = @{@"ord_user":phone,@"products":[arr mj_JSONString],@"money":self.order.ord_money,@"taketype":@"0",@"rev_name":self.address.rev_name,@"rev_phone":self.address.rev_phone,@"rev_addr":self.address.rev_address};
    
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
           
            //怎么回到某一页面？？
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"订单发送失败,请稍后再试"];
    }];
}

@end
