//
//  MCOGoodTableViewCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodTableViewCell.h"
#import "MCOScrollView.h"
#import "MCOGoodDetailItem.h"
@interface MCOGoodTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nowPrice;
@property (weak, nonatomic) IBOutlet UILabel *orginPrice;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation MCOGoodTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setItem:(MCOGoodDetailItem *)item
{
    _item = item;
    self.name.text = [NSString stringWithFormat:@"[%@] %@",item.pro_brand,item.pro_name];
    float discount = [item.pro_discount floatValue];
    float nowPrice = [item.pro_price floatValue] * discount;
    NSString *price = [NSString stringWithFormat:@"%0.1f",nowPrice];
    self.nowPrice.text = [NSString stringWithFormat:@"¥%@",price];
    
    //划掉样式的文字
    NSString *oldPrice = [NSString stringWithFormat:@"原价¥%@",item.pro_price];
    NSUInteger length = [oldPrice length];
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:oldPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(2, length-2)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor grayColor] range:NSMakeRange(2, length-2)];
    [_orginPrice setAttributedText:attri];
    //设置斜体
    _orginPrice.font = [UIFont italicSystemFontOfSize:12];//设置字体为斜体
    

}


@end
