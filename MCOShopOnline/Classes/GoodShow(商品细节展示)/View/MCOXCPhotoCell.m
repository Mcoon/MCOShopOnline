//
//  MCOXCPhotoCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOXCPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "XWScanImage.h"
@interface MCOXCPhotoCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation MCOXCPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
#pragma mark -图片点击放大
    // - 浏览大图点击事件
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
    [_imageView addGestureRecognizer:tapGestureRecognizer1];
    //让UIImageView和它的父类开启用户交互属性
    [_imageView setUserInteractionEnabled:YES];
    
}

// - 浏览大图点击事件
-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap{
//    NSLog(@"点击图片");
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [XWScanImage scanBigImageWithImageView:clickedImageView];
}

-(void)setUrl:(NSString *)url
{
    _url = url;
    NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208:80%@",url];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:urlstr]];
}

@end
