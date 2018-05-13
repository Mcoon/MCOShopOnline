//
//  MCOSelfInfoModifyVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/6.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfInfoModifyVC.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "MCOColor.h"
#import <JMessage/JMessage.h>
@interface MCOSelfInfoModifyVC ()
@property (weak, nonatomic) IBOutlet UITextField *valueField;

@end

@implementation MCOSelfInfoModifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title  = self.name;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modify)];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)modify
{
    
    if(self.valueField.text.length == 0)
    {
        [MBProgressHUD showError:@"内容不能为空！"];
        return;
    }
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = @{@"id":[defaults objectForKey:@"user_phone"],@"key":self.zdm,@"value":self.valueField.text};
    
    [mgr POST:@"http://106.14.145.208/ShopMall/UpdateForUserInfo" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD showError:@"修改失败，请重试！"];
        }
        else
        {
            [MBProgressHUD showSuccess:@"修改成功"];
            
            if([self.zdm isEqualToString:@"user_name"])
            {
                [JMSGUser updateMyInfoWithParameter:self.valueField.text userFieldType:kJMSGUserFieldsNickname completionHandler:^(id resultObject, NSError *error) {
                    if(error !=nil)
                    {
                        NSLog(@"im update error");
                    }
                }];
            }
            else if([self.zdm isEqualToString:@"user_paswprd"])
            {
                NSString *str = [defaults objectForKey:@"user_paswprd"];
                [JMSGUser updateMyPasswordWithNewPassword:self.valueField.text oldPassword:str completionHandler:^(id resultObject, NSError *error) {
                    if(error !=nil)
                    {
                        NSLog(@"im update error");
                    }
                }];
            }
            
            [defaults setObject:self.valueField.text forKey:self.zdm];
            //立马写入到文件
            [defaults synchronize];
            
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD showError:@"网络问题，请稍后再试！"];
    }];
}

@end
