//
//  MCOAddCommonAddrVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/28.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOAddCommonAddrVC.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
@interface MCOAddCommonAddrVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextView *addrField;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@end

@implementation MCOAddCommonAddrVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupNavBar];
    
    self.addrField.layer.cornerRadius = 4;
    self.addrField.layer.borderWidth = 1;
    self.addrField.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    
}
- (void)setupNavBar
{
    self.navigationItem.title = @"新增收货地址";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(addAddr)];
    self.navigationItem.rightBarButtonItem = item;
}


-(void)addAddr
{
    if( self.nameField.text.length==0 || self.phoneField.text.length !=11 || self.addrField.text.length==0)
    {
        [MBProgressHUD showError:@"收货信息不能为空！"];
    }
    else
    {
        // 1.创建请求会话管理者
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        _mgr = mgr;
        
        //支持text/html
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        //resp内容为非json处理方法
        mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict =@{@"ord_phone":[defaults objectForKey:@"user_phone"],@"rev_name":self.nameField.text,@"rev_phone":self.phoneField.text,@"rev_address":self.addrField.text};
        [mgr POST:@"http://106.14.145.208/ShopMall/AddUserCommonAddr" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [MBProgressHUD hideHUD];
            NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            if([resp isEqualToString:@"ok"])
            {
                [MBProgressHUD showSuccess:@"创建成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [MBProgressHUD showError:@"网络错误，请稍后再试！"];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络错误，请稍后再试！"];
        }];
    }
}


@end
