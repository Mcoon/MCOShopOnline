//
//  MCOSettingTableViewController.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/3.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSettingTableViewController.h"
#import "MCOFileTool.h"
#import "XMGLoginRegisterViewController.h"
#import "MCOMeDetails.h"
#import <JMessage/JMessage.h>
#define MCOIsAutoLogin @"isAutoLogin"
#define CachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
static NSString * const ID = @"cell";

@interface MCOSettingTableViewController ()
@property (nonatomic,assign)NSUInteger totalSize;
@end

@implementation MCOSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(-25, 0, 0, 0);
    
    //计算缓存
    [MCOFileTool getFileSize:CachePath completion:^(NSInteger totalsize) {
          _totalSize = totalsize;
        [self.tableView reloadData];
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)setupNavBar
{
    // titleView
    self.navigationItem.title = @"设置";
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:MCOIsAutoLogin])
    {
        return 2;
    }
    else
    {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(section ==0) return 3;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
  
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
      cell.selectionStyle = UITableViewCellSelectionStyleNone;  
    if (indexPath.section ==0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0:
                {
                    cell.textLabel.text = @"个人资料";
                    cell.imageView.image = [UIImage imageNamed:@"friendsRecommentIcon"];
                }
                break;
            case 1:
                {
                    cell.textLabel.text = [self sizeStr];
                    cell.imageView.image = [UIImage imageNamed:@"login_close_icon"];
                }
                break;
            case 2:
                {
                    cell.textLabel.text = @"关于我们";
                    cell.imageView.image = [UIImage imageNamed:@"mine_msg_icon"];
                }
                break;
        }
    }
    else
    {
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        [button addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"退出当前登录" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cell addSubview:button];
    }
    
    
    return cell;
}

// 获取缓存尺寸字符串
- (NSString *)sizeStr
{
    NSInteger totalSize = _totalSize;
    NSString *sizeStr = @"清除缓存";
    // MB KB B
    if (totalSize > 1000 * 1000) {
        // MB
        CGFloat sizeF = totalSize / 1000.0 / 1000.0;
        sizeStr = [NSString stringWithFormat:@"%@(%.1fMB)",sizeStr,sizeF];
    } else if (totalSize > 1000) {
        // KB
        CGFloat sizeF = totalSize / 1000.0;
        sizeStr = [NSString stringWithFormat:@"%@(%.1fKB)",sizeStr,sizeF];
    } else if (totalSize > 0) {
        // B
        sizeStr = [NSString stringWithFormat:@"%@(%.ldB)",sizeStr,totalSize];
    }
    
    return sizeStr;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        switch (indexPath.row) {
            case 0:
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if([defaults boolForKey:MCOIsAutoLogin])//判断登录没有
                {
                    MCOMeDetails *detailVC = [[MCOMeDetails alloc] init];
                    [self.navigationController pushViewController:detailVC animated:YES];
                }
                else
                {
                    XMGLoginRegisterViewController *vc = [[XMGLoginRegisterViewController alloc] init];
                    [self presentViewController:vc animated:YES completion:nil];
                }
            }
                break;
            case 1:
            {
                
                //创建控制器
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定要清除缓存记录嘛？" message:nil preferredStyle:UIAlertControllerStyleAlert];
                //创建按钮
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    // 清空缓存
                    // 删除文件夹里面所有文件
                    [MCOFileTool removeDirectoryPath:CachePath];
                    
                    _totalSize = 0;
                    
                    [self.tableView reloadData];
                }];
                //添加按钮
                [alertVC addAction:action1];
                [alertVC addAction:action2];
                //显示弹框
                [self presentViewController:alertVC animated:YES completion:nil];
             
            }
                break;
            case 2:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MCO团队" message:@"MCO团队为您的方便保障" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
                break;
        }
    }

}

#pragma mark -退出登录
-(void)quit
{
    //创建控制器
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定退出登录吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //创建按钮
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:MCOIsAutoLogin];
        //发送个人详情界面更新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"quitLog" object:nil userInfo:nil];
        
        #pragma mark -im退出
        [JMSGUser logout:^(id resultObject, NSError *error) {
//            if (!error) {
//                //退出登录成功
//                NSLog(@"im quit sucess");
//            } else {
//                //退出登录失败
//            }
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //添加按钮
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    //显示弹框
    [self presentViewController:alertVC animated:YES completion:nil];
    //设置退出标志
    
}



@end
