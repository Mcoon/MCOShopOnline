//
//  MCShopMsgOVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/10.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCShopMsgOVC.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
@interface MCShopMsgOVC ()
@property (weak, nonatomic) IBOutlet UITextView *msgContent;

@end

@implementation MCShopMsgOVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];

    //右上角完成
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(complete)];
}

- (void)setupNavBar
{
    
    self.navigationItem.title = @"活动通知";
    
}

-(void)complete
{
    if(self.msgContent.text.length == 0)
    {
        [MBProgressHUD showError:@"文字内容不能为空"];
    }
    else
    {
        
        [MBProgressHUD showMessage:@"正在发布动态.."];
        [self.msgContent resignFirstResponder];
        //提交服务器发送
        [self upload];
    }
    
}

-(void)upload
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict = @{@"content":self.msgContent.text};
    //formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
    [manager POST:@"http://106.14.145.208/ShopMall/SendMsgToUsers" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"ok"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"发送成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:resp];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //        NSLog(@"上传失败 %@", error);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"发送失败，请稍后再试"];
    }];
}



@end
