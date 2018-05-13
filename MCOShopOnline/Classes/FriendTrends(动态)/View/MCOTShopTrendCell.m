//
//  MCOTShopTrendCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/11.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTShopTrendCell.h"
#import "UIImageView+WebCache.h"
#import "MCOShopTrendItem.h"
@interface MCOTShopTrendCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *photoArea;

@end

@implementation MCOTShopTrendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置圆角
    _iconImage.layer.cornerRadius = 20;
    _iconImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

-(void)setItem:(MCOShopTrendItem *)item
{
    _item = item;
    _name.text = item.mster_name;
    _timeLabel.text =item.uptime;
    _contentLabel.text =item.dyn_content;
    //清除photoArea中所有子控件
    [self clearPhotoArea];
    
    if(item.mster_touxiang.length!=0)
    {
        NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",item.mster_touxiang];
//        [_iconImage sd_setImageWithURL:[NSURL URLWithString:urlstr]];
        [_iconImage sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:[UIImage imageNamed:@"c906b0b826"]];
    }
    if(item.dyn_photots.length!=0)
    {
        [self setPhotos];
    }
}
//设置图片
-(void)setPhotos
{
    //去除最后一个分号
    NSString *photostr = [_item.dyn_photots substringToIndex:[_item.dyn_photots length] - 1];
    NSArray *arr = [photostr componentsSeparatedByString:@";"];
    for (int i = 0; i<arr.count; i++) {
        UIImageView *image = [[UIImageView alloc] init];
        NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",arr[i]];
        [image sd_setImageWithURL:[NSURL URLWithString:urlstr]];
        image.frame = CGRectMake((i % 3) * 125, (i / 3) * 125, 120, 120);
        [self.photoArea addSubview:image];
    }
}

//清除photoArea中所有子控件
-(void)clearPhotoArea
{
    //去除view所有子控件
    for(UIView *view in [self.photoArea subviews])
    {
        [view removeFromSuperview];
    }
}

@end
