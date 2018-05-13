//
//  MCOTMsgVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/12.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTMsgVC.h"

@interface MCOTMsgVC ()

@end

@implementation MCOTMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    self.tableView.contentInset = UIEdgeInsetsMake(38, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    UIImageView *bgview= [[UIImageView alloc] initWithFrame:self.tableView.frame];
    bgview.image = [UIImage imageNamed:@"login_register_background"];
    self.tableView.backgroundView = bgview;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.textLabel.text = @"发货消息";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:@"avatar_vip"];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = @"【注意查收】";
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
