//
//  XMGLoginRegisterView.m
//  BuDeJie
//
//  Created by xiaomage on 16/3/15.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "XMGLoginRegisterView.h"
#import "XMGLoginField.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
#import <JMessage/JMessage.h>
#define MCOIsAutoLogin @"isAutoLogin"
@interface XMGLoginRegisterView ()
@property (weak, nonatomic) IBOutlet UIButton *loginRegisterButton;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property (weak, nonatomic) IBOutlet XMGLoginField *loginPhone;
@property (weak, nonatomic) IBOutlet XMGLoginField *loginPwnd;
@property (weak, nonatomic) IBOutlet XMGLoginField *registerPhone;
@property (weak, nonatomic) IBOutlet XMGLoginField *registerPwnd;

@end

@implementation XMGLoginRegisterView

// 越复杂的界面,封装 有特殊效果界面,也需要封装

+ (instancetype)loginView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

+ (instancetype)registerView
{
     return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    UIImage *image = _loginRegisterButton.currentBackgroundImage;
    
    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    
   // 让按钮背景图片不要被拉伸
    [_loginRegisterButton setBackgroundImage:image forState:UIControlStateNormal];
    //沙盒中取出私好
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.loginPhone.text = [defaults objectForKey:@"user_phone"];
    self.loginPwnd.text = [defaults objectForKey:@"user_paswprd"];
    [super awakeFromNib];
}

- (IBAction)forgetClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"forgetsecure" object:nil userInfo:nil];
}


- (IBAction)register {
//    [self.registerPhone endEditing:YES];
//    [self.registerPwnd endEditing:YES];
//    if(self.registerPhone.text.length!=11)
//    {
//
//        [MBProgressHUD showError:@"请输入正确的手机号"];
//    }
//    else if(self.registerPwnd.text.length==0)
//    {
//        [MBProgressHUD showError:@"请输入密码"];
//    }
//    else
//    {
        //处理注册
//        NSDictionary *dict = @{@"phone":self.registerPhone.text,@"pawssord":self.registerPwnd.text};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"registers" object:nil userInfo:nil];
//    }
}


- (IBAction)loginClick {
    [self.loginPwnd endEditing:YES];
    [self.loginPhone endEditing:YES];
    if(self.loginPhone.text.length!=11)
    {

        [MBProgressHUD showError:@"请输入正确的手机号"];
    }
    else if(self.loginPwnd.text.length==0)
    {
        [MBProgressHUD showError:@"请输入密码"];
    }
    else
    {
        [MBProgressHUD showMessage:@"正在登录..."];
        // 1.创建请求会话管理者
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        _mgr = mgr;
        
        //支持text/html
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        //resp内容为非json处理方法
        mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        /*
         手机号：pro_id
         商品id：good_id
         商品数量：good_num
         */
        NSDictionary *dict = @{@"id":self.loginPhone.text,@"password":self.loginPwnd.text};
        [mgr POST:@"http://106.14.145.208:80/ShopMall/JudgeAppLogin" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [MBProgressHUD hideHUD];
            NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            if([resp isEqualToString:@"error"])
            {
                [MBProgressHUD showError:@"登录失败，请重试！"];
              
                
            }
            else
            {
                [MBProgressHUD showSuccess:@"登录成功"];
                //解析json
                NSArray *arrsp = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSDictionary *dict = arrsp[0];
                //保存用户信息到沙盒里
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:self.loginPhone.text forKey:@"user_phone"];
                [defaults setObject:self.loginPwnd.text forKey:@"user_paswprd"];
                [defaults setBool:YES forKey:MCOIsAutoLogin];
                [defaults setObject:dict[@"user_jifen"] forKey:@"user_jifen"];
                [defaults setObject:dict[@"user_redjf"] forKey:@"user_redjf"];
                if(![dict[@"user_addr"] isKindOfClass:[NSNull class]])
                {
                    [defaults setObject:dict[@"user_addr"] forKey:@"user_addr"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"user_addr"];
                }
                if(![dict[@"user_birth"] isKindOfClass:[NSNull class]])
                {
                    [defaults setObject:dict[@"user_birth"] forKey:@"user_birth"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"user_birth"];
                }
                if(![dict[@"user_name"] isKindOfClass:[NSNull class]])
                {
                    [defaults setObject:dict[@"user_name"] forKey:@"user_name"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"user_name"];
                }
                if(![dict[@"user_sex"] isKindOfClass:[NSNull class]])
                {
                    [defaults setObject:dict[@"user_sex"] forKey:@"user_sex"];
                }
                else
                {
                    [defaults setObject:@"" forKey:@"user_sex"];
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
                
#pragma mark -im登陆
                [JMSGUser loginWithUsername:self.loginPhone.text password:self.loginPhone.text handler:^(NSArray<__kindof JMSGDeviceInfo *> * _Nonnull devices, NSError * _Nonnull error) {
//                    NSLog(@"devices:%@",devices);
                    if (!error) {
//                        NSLog(@"yell");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"imlogSucuess" object:nil userInfo:nil];
                    } else {
//                        NSLog(@"fuck");
                    }
                }  ];
                
                //发送登录成功到主界面界面
                [[NSNotificationCenter defaultCenter] postNotificationName:@"logSucuess" object:nil userInfo:nil];
                
            }
            
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络错误"];
        }];
    }
}

#pragma mark - 界面即将消失
-(void)viewWillDisappear:(BOOL)animated
{
    [MBProgressHUD hideHUD];
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}

@end
