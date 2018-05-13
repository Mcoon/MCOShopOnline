//
//  MCOTalkVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/12.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTalkVC.h"
#import "MCOTalkSubVC.h"
#import "MCOTMsgVC.h"
#import "MCOTitleButton.h"
#import "JCHATConversationListViewController.h"
/** TitleButton被重复点击的通知 */
NSString  * const MCOTitleButtonDidRepeatClickNotification = @"MCOTitleButtonDidRepeatClickNotification";
@interface MCOTalkVC ()<UIScrollViewDelegate>
/** 用来存放所有子控制器view的scrollView */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 标题栏 */
@property (nonatomic, weak) UIView *titlesView;
/** 标题下划线 */
@property (nonatomic, weak) UIView *titleUnderline;
/** 上一次点击的标题按钮 */
@property (nonatomic, weak) MCOTitleButton *previousClickedTitleButton;
@end

@implementation MCOTalkVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
//    self.view.backgroundColor = [UIColor redColor];
    
    // 初始化子控制器
    [self setupAllChildVcs];
    
    // 设置导航条
    [self setupNavBar];
    
    // scrollView
    [self setupScrollView];
    
    // 标题栏
    [self setupTitlesView];
    
    // 添加第0个子控制器的view
    [self addChildVcViewIntoScrollView:0];
}

/**
 *  初始化子控制器
 */
- (void)setupAllChildVcs
{
    [self addChildViewController:[[JCHATConversationListViewController alloc] init]];
    [self addChildViewController:[[MCOTMsgVC alloc] init]];
}
/**
 *  设置导航条
 */
- (void)setupNavBar
{
  
    self.navigationItem.title = @"消息";
    
}

/**
 *  scrollView
 */
- (void)setupScrollView
{
    // 不允许自动修改UIScrollView的内边距
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.scrollsToTop = NO; // 点击状态栏的时候，这个scrollView不会滚动到最顶部
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 添加子控制器的view
    NSUInteger count = self.childViewControllers.count;
    CGFloat scrollViewW = scrollView.frame.size.width;
    scrollView.contentSize = CGSizeMake(count * scrollViewW, 0);
    scrollView.scrollEnabled = NO;
}

/**
 *  标题栏
 */
- (void)setupTitlesView
{
    UIView *titlesView = [[UIView alloc] init];
    titlesView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    titlesView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    [self.view addSubview:titlesView];
    self.titlesView = titlesView;
    
    // 标题栏按钮
    [self setupTitleButtons];
    
    // 标题下划线
    [self setupTitleUnderline];
}
/**
 *  标题栏按钮
 */
- (void)setupTitleButtons
{
    // 文字
    NSArray *titles = @[@"聊天", @"系统消息"];
    NSUInteger count = titles.count;
    
    // 标题按钮的尺寸
    CGFloat titleButtonW = self.titlesView.frame.size.width / count;
    CGFloat titleButtonH = self.titlesView.frame.size.height;
    
    // 创建5个标题按钮
    for (NSUInteger i = 0; i < count; i++) {
        MCOTitleButton *titleButton = [[MCOTitleButton alloc] init];
        titleButton.tag = i;
        [titleButton addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titlesView addSubview:titleButton];
        // frame
        titleButton.frame = CGRectMake(i * titleButtonW, 3, titleButtonW, titleButtonH);
        // 文字
        [titleButton setTitle:titles[i] forState:UIControlStateNormal];
    }
}

/**
 *  标题下划线
 */
- (void)setupTitleUnderline
{
    // 标题按钮
    MCOTitleButton *firstTitleButton = self.titlesView.subviews.firstObject;
    
    // 下划线
    UIView *titleUnderline = [[UIView alloc] init];
    CGRect frame = titleUnderline.frame;
    frame.size.height = 2;
    frame.origin.y = self.titlesView.frame.size.height - frame.size.height;
    titleUnderline.frame = frame;
    titleUnderline.backgroundColor = [firstTitleButton titleColorForState:UIControlStateSelected];
    [self.titlesView addSubview:titleUnderline];
    self.titleUnderline = titleUnderline;
    
    // 切换按钮状态
    firstTitleButton.selected = YES;
    self.previousClickedTitleButton = firstTitleButton;
    
    [firstTitleButton.titleLabel sizeToFit]; // 让label根据文字内容计算尺寸
    CGRect fram2 = self.titleUnderline.frame;
    fram2.size.width = firstTitleButton.titleLabel.frame.size.width + 10;
    self.titleUnderline.frame = fram2;
    CGPoint point = self.titleUnderline.center;
    point.x = firstTitleButton.center.x;
    self.titleUnderline.center = point;
}


#pragma mark - 监听
/**
 *  点击标题按钮
 */
- (void)titleButtonClick:(MCOTitleButton *)titleButton
{
    // 重复点击了标题按钮
    if (self.previousClickedTitleButton == titleButton) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MCOTitleButtonDidRepeatClickNotification object:nil];
    }
    
    // 切换按钮状态
    self.previousClickedTitleButton.selected = NO;
    titleButton.selected = YES;
    self.previousClickedTitleButton = titleButton;
    
    NSUInteger index = titleButton.tag;
    [UIView animateWithDuration:0.25 animations:^{
        // 处理下划线
        CGRect fram2 = self.titleUnderline.frame;
        fram2.size.width = titleButton.titleLabel.frame.size.width + 10;
        self.titleUnderline.frame = fram2;
        CGPoint point = self.titleUnderline.center;
        point.x = titleButton.center.x;
        self.titleUnderline.center = point;
        CGFloat offsetX = self.scrollView.frame.size.width * index;
        self.scrollView.contentOffset = CGPointMake(offsetX, self.scrollView.contentOffset.y);
    } completion:^(BOOL finished) {
        // 添加子控制器的view
        [self addChildVcViewIntoScrollView:index];
    }];
    
    // 设置index位置对应的tableView.scrollsToTop = YES， 其他都设置为NO
    for (NSUInteger i = 0; i < self.childViewControllers.count; i++) {
        UIViewController *childVc = self.childViewControllers[i];
        // 如果view还没有被创建，就不用去处理
        if (!childVc.isViewLoaded) continue;
        
        UIScrollView *scrollView = (UIScrollView *)childVc.view;
        if (![scrollView isKindOfClass:[UIScrollView class]]) continue;
        
        //        if (i == index) { // 是标题按钮对应的子控制器
        //            scrollView.scrollsToTop = YES;
        //        } else {
        //            scrollView.scrollsToTop = NO;
        //        }
        scrollView.scrollsToTop = (i == index);
    }
    
}
#pragma mark - <UIScrollViewDelegate>
    /**
     *  当用户松开scrollView并且滑动结束时调用这个代理方法（scrollView停止滚动的时候）
     */
    
    
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 求出标题按钮的索引
    NSUInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;

    // 点击对应的标题按钮
    MCOTitleButton *titleButton = self.titlesView.subviews[index];
    [self titleButtonClick:titleButton];
}

#pragma mark - 其他
/**
 *  添加第index个子控制器的view到scrollView中
 */
-(void)addChildVcViewIntoScrollView:(NSUInteger)index
{
    UIViewController *childVc = self.childViewControllers[index];

    // 如果view已经被加载过，就直接返回
    if (childVc.isViewLoaded) return;

    // 取出index位置对应的子控制器view
    UIView *childVcView = childVc.view;

    // 设置子控制器view的frame
    CGFloat scrollViewW = self.scrollView.frame.size.width;
    childVcView.frame = CGRectMake(index * scrollViewW, 0, scrollViewW, self.scrollView.frame.size.height);
    // 添加子控制器的view到scrollView中
    [self.scrollView addSubview:childVcView];
}

    
@end
    
