//
//  MCOSendGoodVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/1.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSendGoodVC.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "MCOShopOrder.h"
@interface MCOSendGoodVC ()
@property (weak, nonatomic) IBOutlet UITextField *expNameF;
@property (weak, nonatomic) IBOutlet UITextField *expIdF;

@end

@implementation MCOSendGoodVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"快递信息填写";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"发货" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = item;
    
}


-(void)send
{
    if(self.expIdF.text.length==0 || self.expNameF.text.length==0)
    {
        [MBProgressHUD showError:@"信息请填写完整"];
    }
    else
    {
        [self uploadOrderByExpSend:self.order];
    }
}


//快递派送
-(void)uploadOrderByExpSend:(MCOShopOrder *)order
{
    [MBProgressHUD showMessage:@"订单更新中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict =@{@"ord_user":self.order.user_phone,@"ord_id":self.order.ord_id,@"ord_status":@"1",@"expressname":self.expNameF.text,@"expressid":self.expIdF.text};
    [manager POST:@"http://106.14.145.208/ShopMall/UploadOrderStatus" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"订单更新失败，请稍后再试！"];
            
        }
        else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"订单已更新"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fresh" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"订单更新失败，请稍后再试！"];
    }];
}
@end
