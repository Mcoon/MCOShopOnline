//
//  MCOSelfInfoVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/6.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfInfoVC.h"
#import "MCOTableViewCell.h"
#import "MCOSelfInfoModifyVC.h"
static NSString * const ID = @"mcocell";
@interface MCOSelfInfoVC ()

@end

@implementation MCOSelfInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MCOTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCOTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    switch (indexPath.row) {
        case 0://user_name
        {
           cell.zdm = @"user_name";
            cell.name = @"昵称:";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *value = [defaults objectForKey:@"user_name"];
            if(value.length==0)
            {
                cell.value = @"未设置";
            }
            else
            {
                cell.value = value;
            }
        }
            break;
        case 1://user_paswprd
        {
            cell.zdm = @"user_paswprd";
            cell.name = @"密码:";
            cell.value = @"******";
        }
            break;
        case 2://user_birth
        {
            cell.zdm = @"user_birth";
            cell.name = @"出生日期:";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *value = [defaults objectForKey:@"user_birth"];
            if(value.length==0)
            {
                cell.value = @"未设置";
            }
            else
            {
                cell.value = value;
            }
        }
            break;
        case 3://user_sex
        {
            cell.zdm = @"user_sex";
            cell.name = @"性别:";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *value = [defaults objectForKey:@"user_sex"];
            if(value.length==0)
            {
                cell.value = @"未设置";
            }
            else
            {
                cell.value = value;
            }
        }
            break;
        case 4://user_addr
        {
            cell.zdm = @"user_addr";
            cell.name = @"地址:";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *value = [defaults objectForKey:@"user_addr"];
            if(value.length==0)
            {
                cell.value = @"未设置";
            }
            else
            {
                cell.value = value;
            }
        }
            break;
    }
   
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCOTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MCOSelfInfoModifyVC *vc = [[MCOSelfInfoModifyVC alloc] init];
    vc.zdm = cell.zdm;
    vc.value = cell.value;
    vc.name = cell.name;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
