//
//  MCOSelfOrderCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/14.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfOrderCell.h"
#import "MCOSelfOrder.h"
#import "MCOSelfOrderItem.h"
#import "MCOSelfOrderItemView.h"
#import "UIImageView+WebCache.h"
@interface MCOSelfOrderCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIView *orderArea;
@property (weak, nonatomic) IBOutlet UILabel *totalLable;
@end

@implementation MCOSelfOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];

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

@end
