//
//  MCOTSubTrendCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/11.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTSubTrendCell.h"
#import "UIImageView+WebCache.h"
#import "MCOShopTrendItem.h"
#import "MCOTextTool.h"
#import "XWScanImage.h"
@interface MCOTSubTrendCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *photoArea;
@end

@implementation MCOTSubTrendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置圆角
    _iconImage.layer.cornerRadius = 20;
    _iconImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setItem:(MCOShopTrendItem *)item
{
    _item = item;
    _name.text = item.mster_name;
    _timeLabel.text =item.uptime;
    _contentLabel.text =item.dyn_content;
    //调整控件位置
    [self resetFrame];
    //清除photoArea中所有子控件
    [self clearPhotoArea];
   
    if(item.mster_touxiang.length!=0)
    {
        NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",item.mster_touxiang];
        [_iconImage sd_setImageWithURL:[NSURL URLWithString:urlstr]];
    }
    if(item.dyn_photots.length!=0)
    {
        [self setPhotos];
    }
}


//调整控件frame
-(void)resetFrame
{
    //一行文字的最大宽度
    CGFloat areaWidth = [UIScreen mainScreen].bounds.size.width - 20;
    //计算文字的宽度
    CGFloat contentWidth = [MCOTextTool calculateRowHeight:_item.dyn_content fontSize:16 withWidth:areaWidth];
   //一行高度
    CGFloat height = 20;
    if(contentWidth > height)
    {
        //调整contentLabel控件frame
        CGRect frame = self.contentLabel.frame;
        frame.size.height = ( contentWidth / (height-1) +1 ) * height;
        self.contentLabel.frame = frame;
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
#pragma mark -图片点击放大
        // - 浏览大图点击事件
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
        [image addGestureRecognizer:tapGestureRecognizer1];
        //让UIImageView和它的父类开启用户交互属性
        [image setUserInteractionEnabled:YES];
        
        NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",arr[i]];
        [image sd_setImageWithURL:[NSURL URLWithString:urlstr]];
        image.frame = CGRectMake((i % 3) * 125, (i / 3) * 125, 120, 120);
        [self.photoArea addSubview:image];
    }
}

// - 浏览大图点击事件
-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap{
    //    NSLog(@"点击图片");
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [XWScanImage scanBigImageWithImageView:clickedImageView];
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
