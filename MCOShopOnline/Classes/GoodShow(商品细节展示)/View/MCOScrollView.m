//
//  MCOScrollView.m
//  UIScrollView封装
//
//  Created by Mco on 2018/3/10.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOScrollView.h"
#import "UIImageView+WebCache.h"
#import "XWScanImage.h"
@interface MCOScrollView () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageCrl;
@property (weak, nonatomic) NSTimer *timer;
@end

@implementation MCOScrollView 

+ (instancetype)scrollView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.pageCrl.frame = CGRectMake(self.scrollView.frame.size.width - (self.scrollView.subviews.count * 30)-10, self.scrollView.frame.size.height-30, self.scrollView.subviews.count*30,30);
    
    //根据最新的scrollview尺寸计算imageview的x和宽度
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIImageView *img = self.scrollView.subviews[i];
        CGRect frame = img.frame;
        frame.size.width = self.scrollView.frame.size.width;
        frame.size.height = self.scrollView.frame.size.height;
        frame.origin.x = i * self.scrollView.frame.size.width;
        img.frame = frame;
    }
}

-(void)setImageNames:(NSArray *)imageNames
{
    _imageNames = imageNames;
    
    //调用之前去除之前的所有图片
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
//    self.pageCrl.frame = CGRectMake(self.scrollView.frame.size.width - (imageNames.count * 30 ) - 10, self.scrollView.frame.size.height-30, imageNames.count*30,30);
    self.pageCrl.numberOfPages = imageNames.count;
    for (int i=0; i<imageNames.count; i++) {
        NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208:80%@",imageNames[i]];
//        NSLog(@"%@",urlstr);
        UIImageView *vimg = [[UIImageView alloc] init];
        
#pragma mark -图片点击放大
        // - 浏览大图点击事件
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick1:)];
        [vimg addGestureRecognizer:tapGestureRecognizer1];
        //让UIImageView和它的父类开启用户交互属性
        [vimg setUserInteractionEnabled:YES];
        
        vimg.frame = CGRectMake(i*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width,self.scrollView.frame.size.height);
//        [vimg sd_setImageWithURL:[NSURL URLWithString:urlstr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            vimg.image = image;
//            vimg.frame = CGRectMake(i*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width,self.scrollView.frame.size.height);
//            [self.scrollView addSubview:vimg];
////            NSLog(@"%@",[NSThread mainThread]);
//        }];
        [vimg sd_setImageWithURL:[NSURL URLWithString:urlstr] placeholderImage:[UIImage imageNamed:@"c906b0b826"]];
        [self.scrollView addSubview:vimg];
    }
    
      self.scrollView.contentSize = CGSizeMake(imageNames.count*self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    //开启分业功能
    //以scrollview为一页
    self.scrollView.pagingEnabled = YES;
    
    //定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];

    //修改timer在runkop中的默认模式
    //让定时器一直执行 不会被暂时放置
//    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// - 浏览大图点击事件
-(void)scanBigImageClick1:(UITapGestureRecognizer *)tap{
//    NSLog(@"点击图片");
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [XWScanImage scanBigImageWithImageView:clickedImageView];
}

-(void)nextPage
{
    NSInteger page = (self.pageCrl.currentPage +1) % (_imageNames.count);
    
    [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0) animated:YES];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page=scrollView.contentOffset.x / (scrollView.frame.size.width-10);

    self.pageCrl.currentPage = page;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //停止定时器
    [self.timer invalidate];
    self.timer = nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //开始定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    //修改timer在runkop中的默认模式
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


@end
