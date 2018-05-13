//
//  MCOTGViewController.m
//  MCOShopOnline
//
//  Created by mco on 2018/5/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTGViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
@interface MCOTGViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tgCodeLabel;

@end

@implementation MCOTGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"您的推广";
    [self upload];
}

-(void)upload
{
    // 验证成功
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = @{@"phone_num":[defaults objectForKey:@"user_phone"]};
    [manager POST:@"http://106.14.145.208/ShopMall/BackAppTGCode" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            self.tgCodeLabel.text = resp;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

@end
