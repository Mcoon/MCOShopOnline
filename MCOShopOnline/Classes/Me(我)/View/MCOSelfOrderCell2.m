//
//  MCOSelfOrderCell2.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/15.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfOrderCell2.h"
#import "MCOSelfOrder.h"
#import "MCOSelfOrderItem.h"
#import "MCOSelfOrderItemView.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
#import "MCOExpressItem.h"
@interface MCOSelfOrderCell2()
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIView *orderArea;
@property (weak, nonatomic) IBOutlet UILabel *totalLable;
@property (weak, nonatomic) IBOutlet UIButton *wlButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation MCOSelfOrderCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _wlButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    _wlButton.layer.cornerRadius = 15;
    
    self.submitButton.layer.cornerRadius = 15;
    self.submitButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    
}


-(void)setExtra:(NSString *)extra
{
    self.submitButton.hidden = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setOrder:(MCOSelfOrder *)order
{
    _order =order;
    _titleLable.text =order.ord_time;
    _totalLable.text = [NSString stringWithFormat:@"合计：¥%@ ",order.ord_money];
    
    //移除子控件
    [_orderArea.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i<order.ord_products.count; i++) {
        MCOSelfOrderItem * item = order.ord_products[i];
        
        UIView * view = [[UIView alloc] initWithFrame: CGRectMake(0, 85*i, self.frame.size.width, 80)];
        view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        //图标
        UIImageView *icon = [[UIImageView alloc] init];
        icon.frame = CGRectMake(0, 1, 80, 80);
        NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",item.ord_photo];
        [icon sd_setImageWithURL: [NSURL URLWithString:urlstr]];
        [view addSubview:icon];
        
        //名称
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 1, 200, 36)];
        nameLabel.numberOfLines = 2;
        nameLabel.text = item.ord_name;
        [view addSubview:nameLabel];
        
        //价钱
        float discount = [item.pro_discount floatValue];
        float nowPrice = [item.pro_price floatValue] * discount;
        NSString *price = [NSString stringWithFormat:@"%0.1f",nowPrice];
        UILabel *priceLable = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-65, 1, 60, 36)];
        priceLable.textAlignment = NSTextAlignmentRight;
        priceLable.text = [NSString stringWithFormat:@"¥%@",price];
        [view addSubview:priceLable];
        //数量
        UILabel *numLable = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-65, 41, 60, 36)];
        numLable.textAlignment = NSTextAlignmentRight;
        numLable.text = [NSString stringWithFormat:@"x%@",item.ord_num];
        numLable.textColor = [UIColor darkGrayColor];
        numLable.font =[UIFont systemFontOfSize:13];
        [view addSubview:numLable];
        
        //规格
        UILabel *ggLable = [[UILabel alloc] initWithFrame:CGRectMake(88, 41, 200, 36)];
        ggLable.text = [NSString stringWithFormat:@"规格：%@，%@",item.ord_color,item.ord_size];
        ggLable.textColor = [UIColor darkGrayColor];
        ggLable.font =[UIFont systemFontOfSize:13];
        [view addSubview:ggLable];
        
        [_orderArea addSubview: view];
    }
}
- (IBAction)viewWL {
    MCOExpressItem *item = [[MCOExpressItem alloc] init];
    item.expressName = self.order.ord_expressname;
    item.expressId = self.order.ord_expressid;
    NSDictionary *dict = @{@"exp":item,@"order":self.order};
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"express" object:nil userInfo:dict];
}

- (IBAction)submitOrder {

    [MBProgressHUD showMessage:@"订单确认中..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"user_phone"];
    NSDictionary *dict =@{@"ord_id":self.order.ord_id,@"ord_phone":phone};
    [manager POST:@"http://106.14.145.208/ShopMall/OrderWC" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"订单确认失败，请稍后再试！"];
        }
        else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"订单已确认"];
            //发送通知 刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil userInfo:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
       [MBProgressHUD showError:@"订单确认失败，请稍后再试！"];
    }];
}

@end
