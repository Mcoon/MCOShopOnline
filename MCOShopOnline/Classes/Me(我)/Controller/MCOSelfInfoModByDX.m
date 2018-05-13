//
//  MCOSelfInfoModByDX.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfInfoModByDX.h"
#import <SMS_SDK/SMSSDK.h>
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
@interface MCOSelfInfoModByDX ()
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic, assign) int timeout;
@end

@implementation MCOSelfInfoModByDX

- (void)viewDidLoad {
    [super viewDidLoad];
    if([_type isEqualToString:@"0"])
    {
        self.valueField.placeholder = @"请输入新手机号...";
        self.navigationItem.title = @"手机号";
        self.valueField.keyboardType = UIKeyboardTypeNumberPad;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *phone = [defaults objectForKey:@"user_phone"];
        self.phoneField.text = phone;
        self.phoneField.enabled = NO;
        self.confirmBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        self.sendBtn.enabled = YES;
        [self.sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.sendBtn.alpha=1.0;//透明度
        [self.sendBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    }
    else
    {
        self.valueField.placeholder = @"请输入新密码...";
        self.navigationItem.title = @"忘记密码";
    }
    
    [self.phoneField addTarget:self action:@selector(phonetextChange) forControlEvents:UIControlEventEditingChanged];
     [self.codeField addTarget:self action:@selector(codetextChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.sendBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sendBtn.alpha=0.3;//透明度
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modify)];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)modify
{
    if(self.valueField.text.length == 0 || self.codeField.text.length == 0)
    {
        [MBProgressHUD showError:@"验证信息不能为空！"];
        return;
    }
    if([self.type isEqualToString:@"0"] && self.valueField.text.length!=11)
    {
        [MBProgressHUD showError:@"请输入正确的手机号码！"];
        return;
    }
    [self reKeyBoard];
    [SMSSDK commitVerificationCode:self.codeField.text phoneNumber:self.phoneField.text zone:@"86" result:^(NSError *error) {
        if (!error)
        {
            // 验证成功
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            //支持text/html
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            //resp内容为非json处理方法
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSDictionary *dict = @{@"id":self.phoneField.text,@"key":self.zdm,@"value":self.valueField.text};
            [manager POST:@"http://106.14.145.208/ShopMall/UpdateForUserInfo" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                if([resp isEqualToString:@"ok"])
                {
                    //注册成功
                    [MBProgressHUD showSuccess:@"修改成功！"];
                    
                    if([self.type isEqualToString:@"1"])
                    {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:self.valueField.text forKey:self.zdm];
                    }
                }
                else
                {
                    //注册失败
                    [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                //注册失败
                [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
            }];
        }
        else
        {
            [MBProgressHUD showError:@"验证码错误，请重新填写！"];
        }
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)confirm:(id)sender {
    [self modify];
}



-(void)phonetextChange
{
    if(self.phoneField.text.length ==11)
    {
        self.sendBtn.enabled = YES;
        [self.sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.sendBtn.alpha=1.0;//透明度
    }
}
-(void)codetextChange:(UITextField *)textF
{
    if(textF.text.length == 4) [self.codeField resignFirstResponder];
}

//实现方法//取消textView ,textField的第一响应者即可
- (void)reKeyBoard
{
    [_phoneField resignFirstResponder];
    [_codeField resignFirstResponder];
    [_valueField resignFirstResponder];
}

- (IBAction)sendMsg {
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneField.text zone:@"86"  result:^(NSError *error) {
        
        if (!error)
        {
            [self.codeField becomeFirstResponder];
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
                
//                self.sendBtn.titleLabel.text = strTime;
                [self.sendBtn setTitle:strTime forState:UIControlStateNormal];
                
            });
            
            _timeout--;
        }
    });
    
    // 开启定时器
    dispatch_resume(_timer);
    
}

@end
