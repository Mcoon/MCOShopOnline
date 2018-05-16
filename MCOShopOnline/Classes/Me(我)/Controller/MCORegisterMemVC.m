//
//  MCORegisterMemVC.m
//  MCO电商
//
//  Created by Mco on 2018/3/30.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCORegisterMemVC.h"
#import <SMS_SDK/SMSSDK.h>
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
#import <JMessage/JMessage.h>
@interface MCORegisterMemVC ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *msgCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UITextField *pwsdTF;
@property (weak, nonatomic) IBOutlet UITextField *tgField;

@property (nonatomic, assign) int timeout;
@end

@implementation MCORegisterMemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.completeBtn.layer.cornerRadius = 26;
    
    [self.phoneTF addTarget:self action:@selector(phonetextChange) forControlEvents:UIControlEventEditingChanged];
    [self.msgCodeTF addTarget:self action:@selector(codetextChange:) forControlEvents:UIControlEventEditingChanged];
    [self.pwsdTF addTarget:self action:@selector(codetextChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.sendBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sendBtn.alpha=0.3;//透明度
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

//实现方法//取消textView ,textField的第一响应者即可
- (void)reKeyBoard
{
    [_pwsdTF resignFirstResponder];
    [_phoneTF resignFirstResponder];
    [_msgCodeTF resignFirstResponder];
    [_tgField resignFirstResponder];
}

-(void)phonetextChange
{
    if(self.phoneTF.text.length ==11)
    {
        self.sendBtn.enabled = YES;
        [self.sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.sendBtn.alpha=1.0;//透明度
    }
}
-(void)codetextChange:(UITextField *)textF
{
    self.completeBtn.enabled = (self.msgCodeTF.text.length && self.pwsdTF.text.length && (self.phoneTF.text.length ==11));
    if(textF == self.msgCodeTF)
    {
        if(textF.text.length == 4) [self.msgCodeTF resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)sendClick {
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneTF.text zone:@"86"  result:^(NSError *error) {
        
        if (!error)
        {
            [self.msgCodeTF becomeFirstResponder];
            [MBProgressHUD showSuccess:@"发送成功，注意查收！"];
            self.sendBtn.titleLabel.text = @"重发(60)";
            [self.sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.sendBtn.userInteractionEnabled=NO;//交互关闭
            self.sendBtn.alpha=0.3;//透明度
            [self startCountdown];
//            NSLog(@"%@",[NSThread currentThread]);
            
        }
        else
        {
            [MBProgressHUD showError:@"发送失败！"];
        }
    }];
}


/** 开启倒计时 */
- (void)startCountdown {

    if (_timeout > 0) {
        return;
    }

    _timeout = 60;
    
    // GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeout <= 0 ){// 倒计时结束
            
            // 关闭定时器
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.sendBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                [self.sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                self.sendBtn.userInteractionEnabled = YES;//交互关闭
                self.sendBtn.alpha = 1.0;//透明度
            });
            
        }else{// 倒计时中
            
            // 显示倒计时结果
            
            NSString *strTime = [NSString stringWithFormat:@"重发(%d)", _timeout];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.sendBtn.titleLabel.text = strTime;
                
            });
            
            _timeout--;
        }
    });
    
    // 开启定时器
    dispatch_resume(_timer);
    
}
- (IBAction)completeClick {
    //键盘消失
    [self.msgCodeTF resignFirstResponder];
    
    [SMSSDK commitVerificationCode:self.msgCodeTF.text phoneNumber:self.phoneTF.text zone:@"86" result:^(NSError *error) {
        if (!error)
        {
            // 验证成功
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            //支持text/html
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            //resp内容为非json处理方法
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:self.phoneTF.text forKey:@"phone"];
            [dict setObject:self.pwsdTF.text forKey:@"password"];
            if(self.tgField.text.length > 0)
            {
                [dict setObject:self.tgField.text forKey:@"extendcode"];
            }
//            NSDictionary *dict = @{@"phone":self.phoneTF.text,@"password":self.pwsdTF.text};
//            NSLog(@"%@",dict);
            [manager POST:@"http://106.14.145.208/ShopMall/RegisterForSpeed" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                if([resp isEqualToString:@"ok"])
                {
                    //注册成功
                    [JMSGUser registerWithUsername:self.phoneTF.text password:self.phoneTF.text completionHandler:^(id resultObject, NSError *error) {
                        if(error == nil)
                        {
                            [MBProgressHUD showSuccess:@"注册成功"];
                        }
                        else
                        {
                            [MBProgressHUD showError:@"注册失败，请重试！"];
                        }
                    }];
                    [self dismissModal];
                }
                else
                {
                    //注册失败
                    [MBProgressHUD showError:@"手机号已经注册！"];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                //注册失败
                [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
            }];
        }
        else
        {
            [MBProgressHUD showError:@"验证码错误！"];
        }
    }];
}


@end
