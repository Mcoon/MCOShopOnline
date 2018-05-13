//
//  MCOGoodEditSub1VC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/24.
//  Copyright © 2018年 Mco. All rights reserved.
//
//修改商品的名称、适用人群、主材料、品牌、总价

#import "MCOGoodEditSub1VC.h"
#import "AFNetworking.h"
#import "MCOGoodDetailItem.h"
#import "MBProgressHUD+XMG.h"
@interface MCOGoodEditSub1VC ()
@property (weak, nonatomic) IBOutlet UITextField *valueLable;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@end

@implementation MCOGoodEditSub1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
}

-(void)setGood:(MCOGoodDetailItem *)good
{
    _good = good;
}
-(void)setKey:(NSString *)key
{
    _key = key;
}
-(void)setIndex:(NSInteger)index
{
    _index = index;
    switch (index) {
        case 0:
        {
            self.navigationItem.title = @"商品名称";
        }
            break;
        case 2:
        {
            self.navigationItem.title = @"商品适用人群";
        }
            break;
        case 3:
        {
            self.navigationItem.title = @"商品主要材料";
        }
            break;
        case 4:
        {
            self.navigationItem.title = @"商品品牌";
        }
            break;
        case 7:
        {
            self.navigationItem.title = @"商品原价";
        }
            break;
        case 12:
        {
            self.navigationItem.title = @"商品积分";
        }
            break;
            
    }
}

- (void)setupNavBar
{

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(modifyGood)];
    
    self.navigationItem.rightBarButtonItem = item;
    
}
-(void)modifyGood
{
    if(self.valueLable.text.length ==0)
    {
        [MBProgressHUD showError:@"新值不能为空！"];
        return;
    }
    else
    {
        [self.valueLable resignFirstResponder];
        
        [MBProgressHUD showMessage:@"正在修改中..."];
        // 1.创建请求会话管理者
        AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
        _mgr = mgr;
        //支持text/html
        mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        //resp内容为非json处理方法
        mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *dict = @{@"pro_id":self.good.pro_id,@"key":self.key,@"value":self.valueLable.text};
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
