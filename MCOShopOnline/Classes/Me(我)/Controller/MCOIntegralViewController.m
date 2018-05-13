//
//  MCOIntegralViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/4.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOIntegralViewController.h"
#import "MCOIntegralExplanationVC.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "MCORefRecordVC.h"
@interface MCOIntegralViewController ()
@property (weak, nonatomic) IBOutlet UIView *whiteView;
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UILabel *whiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *txBtn;
@property (weak, nonatomic) IBOutlet UITextField *zfbid;

@end

@implementation MCOIntegralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupNavBar];

    self.txBtn.layer.cornerRadius = 15;
    self.redView.layer.masksToBounds = YES;
    self.whiteView.layer.cornerRadius = 65;
    self.whiteView.layer.masksToBounds = YES;
    self.redView.layer.cornerRadius = 65;
    self.redView.layer.masksToBounds = YES;
    
    [self queryJF];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reKeyBoard)];
      [self.view addGestureRecognizer:tap];
}
//实现方法//取消textView ,textField的第一响应者即可
- (void)reKeyBoard
{
    [_zfbid resignFirstResponder];
    
}

/**
 *  设置导航条
 */
- (void)setupNavBar
{
    self.navigationItem.title = @"我的积分"; 
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"积分说明" style:UIBarButtonItemStylePlain target:self action:@selector(viewIntegralExap)];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)viewIntegralExap
{
    MCOIntegralExplanationVC *vc = [[MCOIntegralExplanationVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)txClick {
    if([self.moneyLabel.text isEqualToString:@"0"])
    {
        [MBProgressHUD showError:@"暂无金额可提现"];
    }
    else
    {
        if(self.zfbid.text.length ==0 )
        {
            [MBProgressHUD showError:@"请输入提现的支付宝账户"];
        }
        else
        {
            [self uploadRefReq];
        }
    }
}

- (IBAction)viewRecord {
    MCORefRecordVC *vc = [[MCORefRecordVC alloc] init];
    vc.status = @"0";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -提交提现申请
-(void)uploadRefReq
{
    
    [MBProgressHUD showMessage:@"提交提现申请..."];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"user_phone":[defaults objectForKey:@"user_phone"],@"zfbid":self.zfbid.text,@"money":self.moneyLabel.text};
    [mgr POST:@"http://106.14.145.208/ShopMall/SubmitReflectReq" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqual:@"error"])
        {
            [MBProgressHUD showError:@"网络失败，请稍后再试！"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if([resp isEqual:@"ok"])
        {
            [MBProgressHUD showSuccess:@"提交成功，正在处理中！"];
           [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBProgressHUD showError:resp];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络失败，请稍后再试！"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


#pragma mark - 查询积分
-(void)queryJF
{
    [MBProgressHUD showMessage:@"查询积分中..."];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"user_phone":[defaults objectForKey:@"user_phone"]};
    [mgr POST:@"http://106.14.145.208/ShopMall/BackAppUserJF" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqual:@"error"])
        {
            [MBProgressHUD showError:@"网络失败，请稍后再试！"];
             [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSArray *arrsp = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSDictionary *dict = arrsp[0];
            NSString *whitejf = dict[@"whitejf"];
            NSString *redjf = dict[@"redjf"];
            self.redLabel.text = redjf;
            self.whiteLabel.text = whitejf;
            NSInteger c = redjf.integerValue / 20000;
            self.moneyLabel.text = [NSString stringWithFormat:@"%ld",100*c];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络失败，请稍后再试！"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
