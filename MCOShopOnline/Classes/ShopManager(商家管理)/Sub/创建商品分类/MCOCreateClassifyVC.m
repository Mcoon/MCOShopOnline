//
//  MCOCreateClassifyVC.m
//  MCO电商
//
//  Created by Mco on 2018/4/1.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOCreateClassifyVC.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
@interface MCOCreateClassifyVC ()
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameF;

@end

@implementation MCOCreateClassifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameF addTarget:self action:@selector(textchange) forControlEvents:UIControlEventEditingChanged];
    self.createBtn.layer.cornerRadius = 10;
}
-(void)textchange
{
    self.createBtn.enabled = self.nameF.text.length;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissclick {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)createClick:(id)sender {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict = @{@"classifyname":self.nameF.text};
    //            NSLog(@"%@",dict);
    [MBProgressHUD showMessage:@"创建中..." toView:self.view];
    [manager POST:@"http://106.14.145.208/ShopMall/CreateGoodClassify" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"ok"])
        {
           [MBProgressHUD showSuccess:@"创建成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //注册失败
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"网络发生错误，请稍后再试！"];
    }];
    
}

@end
