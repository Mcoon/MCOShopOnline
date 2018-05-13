//
//  MCOQueryCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOQueryCell.h"
#import "MCOShopGoodItem.h"
#import "UIImageView+WebCache.h"
@interface MCOQueryCell()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *presentPrice;
@property (weak, nonatomic) IBOutlet UILabel *originalPrice;

@end

@implementation MCOQueryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setItem:(MCOShopGoodItem *)item
{
    _item = item;
    _name.text = [NSString stringWithFormat:@"[%@] %@",item.pro_brand,item.pro_name];
    float discount = [item.pro_discount floatValue];
    float nowPrice = [item.pro_price floatValue] * discount;
    NSString *price = [NSString stringWithFormat:@"%0.1f",nowPrice];
    _presentPrice.text = [NSString stringWithFormat:@"¥%@",price];

    //划掉样式的文字
    NSString *oldPrice = [NSString stringWithFormat:@"原价¥%@",item.pro_price];
    NSUInteger length = [oldPrice length];
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:oldPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(2, length-2)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor grayColor] range:NSMakeRange(2, length-2)];
    [_originalPrice setAttributedText:attri];
    //设置斜体
    _originalPrice.font = [UIFont italicSystemFontOfSize:12];//设置字体为斜体
    
    //不打折时候隐藏
    _originalPrice.hidden = !(discount<1.0);

    NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",[item.pro_photo componentsSeparatedByString:@";"][0]];
    [_image sd_setImageWithURL:[NSURL URLWithString:urlstr]];
}

@end
