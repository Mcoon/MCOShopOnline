//
//  MCOGoodEditSub2VC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/25.
//  Copyright © 2018年 Mco. All rights reserved.
//修改产品说明信息

#import "MCOGoodEditSub2VC.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
#import "MCOGoodDetailItem.h"
@interface MCOGoodEditSub2VC ()
@property (weak, nonatomic) IBOutlet UITextView *valueField;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@end

@implementation MCOGoodEditSub2VC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavBar];
}

- (void)setupNavBar
{
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modifyGood)];
    
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.title = @"产品说明";
    
}

-(void)modifyGood
{
    if(self.valueField.text.length ==0)
    {
        [MBProgressHUD showError:@"新值不能为空！"];
        return;
    }
    else
    {
        [self.valueField resignFirstResponder];
        
        [MBProgressHUD showMessage:@"正在修改中..."];
        // 1.创建请求会话管理者
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        _mgr = mgr;
        //支持text/html
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        //resp内容为非json处理方法
        mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *dict = @{@"pro_id":self.good.pro_id,@"key":@"pro_describe",@"value":self.valueField.text};
        [mgr POST:@"http://106.14.145.208/ShopMall/ModifyGood" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             [MBProgressHUD hideHUD];
             
             if([resp isEqualToString:@"error"])
             {
                 [MBProgressHUD showError:@"网络错误，请重试！"];
             }
             else
             {
                 
                 [MBProgressHUD showSuccess:@"修改成功"];
                 [self.navigationController popViewControllerAnimated:YES];
             }
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             [MBProgressHUD hideHUD];
             [MBProgressHUD showError:@"网络错误，请重试！"];
         }];
        
    }
    
    
}
//界面即将消失时，取消请求任务
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}
@end
