//
//  MCOGoodSubViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodSubViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "MCOTextColor.h"
#import "MCOGoodDetailItem.h"
@interface MCOGoodSubViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MCOGoodSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 500);
   
    //指定位置设置圆角
    /*
     * UIRectCornerTopLeft
     * UIRectCornerTopRight
     * UIRectCornerBottomLeft
     * UIRectCornerBottomRight
     * UIRectCornerAllCorners
     */
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
}

-(void)setItem:(MCOGoodDetailItem *)item
{
    _item = item;
    [self.tableView reloadData];
}

// 禁止子视图响应父视图的手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.view]) {
        return NO;
    }
    return YES;
    
}


- (IBAction)close {
    [self dismissSemiModalViewWithCompletion:nil];
}


#pragma mark -tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.row) {
        case 0:
        {
            
            cell.textLabel.text = [NSString stringWithFormat:@"宝贝品牌  %@",_item.pro_brand];
             [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"宝" toSecondW:@"牌" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 1:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"宝贝分类  %@",_item.pro_classify];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"宝" toSecondW:@"类" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 2:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"适用人群  %@",_item.pro_suitperson];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"适" toSecondW:@"群" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 3:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"主要材料  %@",_item.pro_material];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"主" toSecondW:@"料" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 4:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"宝贝尺寸  %@",_item.pro_size];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"宝" toSecondW:@"寸" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 5:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"宝贝颜色  %@",_item.pro_color];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"宝" toSecondW:@"色" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 6:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"可得积分  %@",_item.pro_jfvalue];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"可" toSecondW:@"分" color:[UIColor darkGrayColor] size:13];
        }
            break;
        case 7:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"描述信息  %@",_item.pro_describe];
            [MCOTextColor LabelAttributedString:cell.textLabel firstW:@"描" toSecondW:@"息" color:[UIColor darkGrayColor] size:13];
        }
            break;
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textLabel sizeToFit];
   
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row <= 3) return 40;
    else if(indexPath.row <7 ) return 50;
    else return 80;
}
@end
