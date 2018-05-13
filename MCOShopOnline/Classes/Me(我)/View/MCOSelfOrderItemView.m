//
//  MCOSelfOrderItemView.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/14.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfOrderItemView.h"
#import "UIImageView+WebCache.h"
#import "MCOSelfOrderItem.h"
@interface MCOSelfOrderItemView()
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ggLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLable;
@end

@implementation MCOSelfOrderItemView



+(instancetype)fastView
{
    NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:@"MCOSelfOrderItemView"owner:self options:nil];
    return  [nibView objectAtIndex:0];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //ARRewardView : 自定义的view名称
        NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:@"MCOSelfOrderItemView"owner:self options:nil];
        UIView *backView = [nibView objectAtIndex:0];
        backView.frame = frame;
        [self addSubview:backView];
    }
    return self;
}

-(void)setItem:(MCOSelfOrderItem *)item
{
    _item = item;
    _nameLabel.text = _item.ord_name;
    _ggLabel.text = [NSString stringWithFormat:@"%@ %@",_item.ord_color,_item.ord_size];
    _nameLabel.text = _item.ord_num;
    float discount = [_item.pro_discount floatValue];

    if(discount<1.0)
    {
        float nowPrice = [_item.pro_price floatValue] * discount;
        NSString *price = [NSString stringWithFormat:@"%0.1f",nowPrice];
        //划掉样式的文字
        NSString *oldPrice = [NSString stringWithFormat:@"¥%@",_item.pro_price];
        NSUInteger length = [oldPrice length];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:oldPrice];
        [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(2, length-2)];
        [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor grayColor] range:NSMakeRange(2, length-2)];
        
        
        _priceLabel.text = [NSString stringWithFormat:@"%@ ¥%@",[attri string],price];
    }
    else
    {
        _priceLabel.text = [NSString stringWithFormat:@"¥%@",_item.pro_price];
    }

    NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",_item.ord_photo];
    [_iconImage sd_setImageWithURL: [NSURL URLWithString:urlstr]];
}


@end
