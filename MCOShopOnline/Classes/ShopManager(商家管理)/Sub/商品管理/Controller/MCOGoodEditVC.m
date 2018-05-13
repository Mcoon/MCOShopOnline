//
//  MCOGoodEditVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/24.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodEditVC.h"
#import "MCOGoodDetailItem.h"
#import "MCOGoodEditSub1VC.h"
#import "MCOGoodEditSub2VC.h"
#import "MCOGoodEditSub3VC.h"
#import "MCOGoodEditSub4VC.h"
#import "MCOGoodEditSub5VC.h"
#import "MCOGoodEditSub6VC.h"
@interface MCOGoodEditVC ()
@property (nonatomic,strong)NSArray *dataArr;
@end

@implementation MCOGoodEditVC
-(NSArray *)dataArr
{
    if(_dataArr == nil)
    {
        _dataArr = @[@"商品名称修改",@"商品分类修改",@"商品适用人群修改",@"商品主材料修改",@"商品品牌修改",@"商品尺寸修改",@"商品颜色修改",@"商品原价修改",@"商品折扣修改",@"产品说明修改",@"产品图片修改",@"产品宣传图片修改",@"商品积分修改"];
    }
    return _dataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

-(void)setGood:(MCOGoodDetailItem *)good
{
    _good = good;
    [self setupNavBar];
}

- (void)setupNavBar
{
    self.navigationItem.title = _good.pro_name;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = self.dataArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     @[@"商品名称修改",@"商品分类修改",@"商品适用人群修改",@"商品主材料修改",@"商品品牌修改",@"商品尺寸修改",@"商品颜色修改",@"商品原价修改",@"商品折扣修改",@"产品说明修改",@"产品图片修改",@"产品宣传图片修改，@"商品积分修改“"];
     pro_id int auto_increment primary key,
     pro_name nvarchar(100) not null,
     pro_classify nvarchar(50) not null,
     pro_suitperson nvarchar(20) null,
     pro_material nvarchar(100) null,
     pro_brand nvarchar(50) null,
     pro_size nvarchar(200) not null,
     pro_color nvarchar(200) not null,
     pro_price float not null,
     pro_discount float default 0,
     pro_describe nvarchar(300) null,
     pro_photo nvarchar(500) null,
     pro_describephoto nvarchar(500) null,
     pro_available nvarchar(1) null default'1'，
     pro_jfvalue int not null
     */
    switch (indexPath.row) {
        case 0:
            {
                MCOGoodEditSub1VC *vc = [[MCOGoodEditSub1VC alloc] init];
                vc.good = self.good;
                vc.key = @"pro_name";
                vc.index = indexPath.row;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 1:
        {
            MCOGoodEditSub4VC *vc = [[MCOGoodEditSub4VC alloc] init];
            vc.good = self.good;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            MCOGoodEditSub1VC *vc = [[MCOGoodEditSub1VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_suitperson";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            MCOGoodEditSub1VC *vc = [[MCOGoodEditSub1VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_material";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            MCOGoodEditSub1VC *vc = [[MCOGoodEditSub1VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_brand";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            MCOGoodEditSub6VC *vc = [[MCOGoodEditSub6VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_size";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:
        {
            MCOGoodEditSub6VC *vc = [[MCOGoodEditSub6VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_color";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 7:
        {
            MCOGoodEditSub1VC *vc = [[MCOGoodEditSub1VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_price";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 8:
        {
            MCOGoodEditSub5VC *vc = [[MCOGoodEditSub5VC alloc] init];
            vc.good = self.good;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 9:
        {
            MCOGoodEditSub2VC *vc = [[MCOGoodEditSub2VC alloc] init];
            vc.good = self.good;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 10:
        {
            MCOGoodEditSub3VC *vc = [[MCOGoodEditSub3VC alloc] init];
            vc.good = self.good;
            vc.type = @"0";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 11:
        {
            MCOGoodEditSub3VC *vc = [[MCOGoodEditSub3VC alloc] init];
            vc.good = self.good;
            vc.type = @"1";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 12:
        {
            MCOGoodEditSub1VC *vc = [[MCOGoodEditSub1VC alloc] init];
            vc.good = self.good;
            vc.key = @"pro_jfvalue";
            vc.index = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        
    }
}

@end
