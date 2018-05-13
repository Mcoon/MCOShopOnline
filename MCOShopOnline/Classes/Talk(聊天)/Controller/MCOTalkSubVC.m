//
//  MCOTalkSubVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/12.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTalkSubVC.h"
#import "ChatViewController.h"
#import "ViewController.h"
@interface MCOTalkSubVC ()

@end

@implementation MCOTalkSubVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    // 不使用分割线
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(38, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIImageView *bgview= [[UIImageView alloc] initWithFrame:self.tableView.frame];
    bgview.image = [UIImage imageNamed:@"login_register_background"];
    self.tableView.backgroundView = bgview;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"celll"];
    cell.imageView.image = [UIImage imageNamed:@"c906b0b826"];
    cell.textLabel.text = @"商家频道";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = @"有问题，问商家哦～";
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UIStoryboard *storyboardcart = [UIStoryboard storyboardWithName:NSStringFromClass([ViewController class]) bundle:nil];
    ViewController *vc = [storyboardcart instantiateInitialViewController];;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
