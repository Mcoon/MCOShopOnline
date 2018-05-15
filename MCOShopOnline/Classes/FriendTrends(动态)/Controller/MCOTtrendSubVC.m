//
//  MCOTtrendSubVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/11.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTtrendSubVC.h"
#import "AFNetworking.h"
#import "MCOTSubTrendCell.h"
#import "MCOShopTrendItem.h"
#import "MCOTextTool.h"
#import "UIImageView+WebCache.h"
static NSString * const ID = @"subtrendcell";
@interface MCOTtrendSubVC ()
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@property(nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation MCOTtrendSubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    // 处理cell间距,默认tableView分组样式,有额外头部和尾部间距
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 10;
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOTSubTrendCell" bundle:nil] forCellReuseIdentifier:ID];
}

-(void)setItem:(MCOShopTrendItem *)item
{
    _item = item;
    [self.tableView reloadData];
    if(_item.mster_touxiang.length != 0)    [self setupNavBar];
        

}

- (void)setupNavBar
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *topview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [view addSubview:topview];
    topview.backgroundColor = [UIColor redColor];
    topview.contentMode = UIViewContentModeScaleToFill;
    topview.clipsToBounds = YES;
    //设置圆角
    topview.layer.cornerRadius = 20;
    topview.layer.masksToBounds = YES;
    self.navigationItem.titleView = view;
    [topview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://106.14.145.208%@",_item.mster_touxiang]]];
    
    [topview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://106.14.145.208%@",_item.mster_touxiang]] placeholderImage:[UIImage imageNamed:@"c906b0b826"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCOTSubTrendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.item = _item;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat totalSize = 60;
    //一行文字的最大宽度
    CGFloat areaWidth = [UIScreen mainScreen].bounds.size.width - 20;
    //计算文字的宽度
    CGFloat contentWidth = [MCOTextTool calculateRowHeight:_item.dyn_content fontSize:16 withWidth:areaWidth];
    //一行高度
    CGFloat height = 20;
    totalSize += ( contentWidth / (height-1) +1 ) * height;
    
    //只有文字内容
    if(_item.dyn_photots.length==0) return totalSize;
        
        
  //查找；个数，减去1就是图片个数
    NSArray *array = [_item.dyn_photots componentsSeparatedByString:@";"];
    NSInteger count = [array count] - 1;
    if(count % 3 == 0)
    {
        totalSize += (count/3)*125;
    }
    else
    {
        totalSize += (count/3+1)*125;
    }
    
    return totalSize;
}


@end
