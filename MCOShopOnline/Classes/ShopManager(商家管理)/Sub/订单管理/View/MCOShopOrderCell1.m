//
//  MCOShopOrderCell1.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/26.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOShopOrderCell1.h"
#import "MCOShopOrder.h"
#import "UIImageView+WebCache.h"
#import "MCOSelfOrderItem.h"
@interface MCOShopOrderCell1()
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIView *productsArea;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *addrBtn;

@end

@implementation MCOShopOrderCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _sendButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    _sendButton.layer.cornerRadius = 15;
    _addrBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    _addrBtn.layer.cornerRadius = 15;
    _iconImage.layer.cornerRadius = 18;
    _iconImage.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setIndex:(NSInteger)index
{
    _index = index;
    
    if(index != 0)
    {
        [_sendButton setTitle:@"查看物流" forState:UIControlStateNormal];
    }
}

-(void)setOrder:(MCOShopOrder *)order
{
    _order = order;
    
    _nameLabel.text = order.user_name;
    _phoneLabel.text = [NSString stringWithFormat:@"手机号 %@",order.user_phone];
    _orderIdLabel.text = [NSString stringWithFormat:@"订单号 %@",order.ord_id];
    _totalLabel.text = [NSString stringWithFormat:@"合计：¥%@ ",order.ord_money];
    if(order.user_touxiang !=nil)
    {
        [_iconImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://106.14.145.208%@",order.user_touxiang]]];
    }
    //移除子控件
    [_productsArea.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
        
        [_productsArea addSubview: view];
    }
}
- (IBAction)buttonClick:(UIButton *)sender {
    if([sender.titleLabel.text isEqualToString:@"发货"])
    {
        
        NSDictionary *dict = @{@"order":self.order};
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendGood" object:nil userInfo:dict];
    }
    else
    {
        NSDictionary *dict = @{@"order":self.order};
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewExpress2" object:nil userInfo:dict];
    }
}

- (IBAction)viewAddress {
    NSDictionary *dict = @{@"order":self.order};
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"viewAddr" object:nil userInfo:dict];
}



@end
