//
//  MCOUploadGood.m
//  MCO电商
//
//  Created by Mco on 2018/4/1.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOUploadGood.h"
#import "MCOCreateClassifyVC.h"
#import "AFNetworking.h"
#import "MCOUploadGoodStep2.h"
#import "MCOGood.h"
#import "MBProgressHUD+XMG.h"
@interface MCOUploadGood ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameF;
@property (weak, nonatomic) IBOutlet UITextField *brandF;
@property (weak, nonatomic) IBOutlet UITextField *classifyF;
@property (weak, nonatomic) IBOutlet UITextField *suitF;
@property (weak, nonatomic) IBOutlet UITextField *materialF;
@property (weak, nonatomic) IBOutlet UITextField *priceF;
@property (weak, nonatomic) IBOutlet UITextField *countF;
@property (weak, nonatomic) IBOutlet UITextView *descripeTV;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *jifenF;

@property (strong,nonatomic) NSArray *classifyArr;

@end

@implementation MCOUploadGood

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigationItem.title = @"创建新商品";
    self.descripeTV.layer.borderWidth = 0.2;
    self.descripeTV.layer.borderColor = UIColor.grayColor.CGColor;
    self.descripeTV.layer.cornerRadius = 5;
    self.descripeTV.delegate = self;
    self.nextBtn.layer.cornerRadius = 20;
   

    [self.nameF addTarget:self action:@selector(textchange) forControlEvents:UIControlEventEditingChanged];
    [self.brandF addTarget:self action:@selector(textchange) forControlEvents:UIControlEventEditingChanged];
    [self.suitF addTarget:self action:@selector(textchange) forControlEvents:UIControlEventEditingChanged];
    [self.materialF addTarget:self action:@selector(textchange) forControlEvents:UIControlEventEditingChanged];
    [self.priceF addTarget:self action:@selector(textchange) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)textchange
{
    self.nextBtn.enabled = ((self.nameF.text.length>0) && (self.brandF.text.length>0) && (self.suitF.text.length>0) && (self.materialF.text.length>0) && (self.priceF.text.length>0));
//    self.nextBtn.enabled = YES;
}

-(NSArray *)classifyArr
{
    if(_classifyArr == nil)
    {
        _classifyArr = [[NSArray alloc] init];
    }
    return _classifyArr;
}

-(void)getClassify
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager POST:@"http://106.14.145.208/ShopMall/BackAppClassify" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(![resp isEqualToString:@"error"])
        {
            if(resp.length>0)
            {
                NSArray *array = [resp componentsSeparatedByString:@","];
                self.classifyArr = array;
            }
            
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bgScrollView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height-44);
    self.bgScrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height+180);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    CGPoint point = self.bgScrollView.contentOffset;
    point = CGPointMake(point.x, 0);
    [UIView animateWithDuration:0.25 animations:^{
        self.bgScrollView.contentOffset = point;
    }];
   
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CGPoint point = self.bgScrollView.contentOffset;
    point = CGPointMake(point.x, 0);
    [UIView animateWithDuration:0.25 animations:^{
        self.bgScrollView.contentOffset = point;
    }];
    return YES;
}
- (IBAction)addClassifyClick {
    MCOCreateClassifyVC *vc = [[MCOCreateClassifyVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)nextClick {
    if(self.classifyF.text.length>0 && self.countF.text.length>0 && self.jifenF.text.length>0)
    {
        MCOUploadGoodStep2 *vc2 = [[MCOUploadGoodStep2 alloc] init];
        NSMutableDictionary *good = [NSMutableDictionary dictionary];
        [good setValue:self.nameF.text forKey:@"pro_name"];
        [good setValue:self.brandF.text forKey:@"pro_brand"];
        [good setValue:self.classifyF.text forKey:@"pro_classify"];
        [good setValue:self.suitF.text forKey:@"pro_suitperson"];
        [good setValue:self.materialF.text forKey:@"pro_material"];
        [good setValue:self.priceF.text forKey:@"pro_price"];
        [good setValue:self.countF.text forKey:@"pro_discount"];
        [good setValue:self.descripeTV.text forKey:@"pro_describe"];
        [good setValue:self.jifenF.text forKey:@"pro_jfvalue"];
        vc2.good = good ;
        [self.navigationController pushViewController:vc2 animated:YES];
    }
    else{
        [MBProgressHUD showError:@"请填写信息完成"];
    }
  
}

@end
