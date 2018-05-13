//
//  MCOViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOViewController.h"
#import "MCOMeVC.h"
#import "MCOCartViewController.h"
#import "MCOTalkVC.h"
#import "MCOShopVC.h"
#import "MCOTtrendsVC.h"
#import "UIImage+Image.h"
#import "MCONavigationController.h"

@interface MCOViewController ()

@end

@implementation MCOViewController

// 只会调用一次
+ (void)load
{
    // 获取哪个类中UITabBarItem
    UITabBarItem *item = [UITabBarItem appearanceWhenContainedIn:self, nil];
    
    // 设置按钮选中标题的颜色:富文本:描述一个文字颜色,字体,阴影,空心,图文混排
    // 创建一个描述文本属性的字典
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    [item setTitleTextAttributes:attrs forState:UIControlStateSelected];
    
    // 设置字体尺寸:只有设置正常状态下,才会有效果
    NSMutableDictionary *attrsNor = [NSMutableDictionary dictionary];
    attrsNor[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [item setTitleTextAttributes:attrsNor forState:UIControlStateNormal];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1 添加子控制器(5个子控制器) -> 自定义控制器 -> 划分项目文件结构
    [self setupAllChildViewController];
    
    // 2 设置tabBar上按钮内容 -> 由对应的子控制器的tabBarItem属性
    [self setupAllTitleButton];
    
    // 处理cell间距,默认tableView分组样式,有额外头部和尾部间距
    
   
    
}

#pragma mark - 添加所有子控制器
- (void)setupAllChildViewController
{
    // 店铺
    UIStoryboard *storyboardshop = [UIStoryboard storyboardWithName:NSStringFromClass([MCOShopVC class]) bundle:nil];
    MCOShopVC *shopVc = [storyboardshop instantiateInitialViewController];;
    MCONavigationController *nav = [[MCONavigationController alloc] initWithRootViewController:shopVc];
    // initWithRootViewController:push
    [self addChildViewController:nav];
    
    // 动态
    MCOTtrendsVC *newVc = [[MCOTtrendsVC alloc] init];
    MCONavigationController *nav1 = [[MCONavigationController alloc] initWithRootViewController:newVc];
    [self addChildViewController:nav1];
    
    // 聊天
    MCOTalkVC *talkVc = [[MCOTalkVC alloc] init];
     MCONavigationController *nav2 = [[MCONavigationController alloc] initWithRootViewController:talkVc];
    [self addChildViewController:nav2];
    
    // 购物车
    UIStoryboard *storyboardcart = [UIStoryboard storyboardWithName:NSStringFromClass([MCOCartViewController class]) bundle:nil];
    MCOCartViewController *cartVc = [storyboardcart instantiateInitialViewController];
    MCONavigationController *nav3 = [[MCONavigationController alloc] initWithRootViewController:cartVc];
    [self addChildViewController:nav3];
    
    // 我
    UIStoryboard *storyboardme = [UIStoryboard storyboardWithName:NSStringFromClass([MCOMeVC class]) bundle:nil];
    //加载箭头指向控制器
    MCOMeVC *meVc = [storyboardme instantiateInitialViewController];
    MCONavigationController *nav4 = [[MCONavigationController alloc] initWithRootViewController:meVc];
    [self addChildViewController:nav4];
    
}

// 设置tabBar上所有按钮内容
- (void)setupAllTitleButton
{
    // 0.店铺
    UINavigationController *nav = self.childViewControllers[0];
    nav.tabBarItem.title = @"店铺";
    nav.tabBarItem.image = [UIImage imageNamed:@"tabBar_essence_icon"];
    // 快速生成一个没有渲染图片
    nav.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_essence_click_icon"];
    
    // 1:动态
    UINavigationController *nav1 = self.childViewControllers[1];
    nav1.tabBarItem.title = @"动态";
    nav1.tabBarItem.image = [UIImage imageNamed:@"tabBar_new_icon"];
    nav1.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_new_click_icon"];
    
    // 2:聊天
    MCOTalkVC *tablkVc = self.childViewControllers[2];
    tablkVc.tabBarItem.image = [UIImage imageOriginalWithName:@"tabBar_publish_icon"];
    tablkVc.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_publish_click_icon"];
    
    // 3.购物车
    UINavigationController *nav3 = self.childViewControllers[3];
    nav3.tabBarItem.title = @"购物车";
    nav3.tabBarItem.image = [UIImage imageNamed:@"tabBar_me_icon"];
    nav3.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_me_click_icon"];
    
    // 4.我
    UINavigationController *nav4 = self.childViewControllers[4];
    nav4.tabBarItem.title = @"我";
    nav4.tabBarItem.image = [UIImage imageNamed:@"tabBar_friendTrends_icon"];
    nav4.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_friendTrends_click_icon"];
}


@end
