//
//  MCOMeDetails.m
//  MCO电商
//
//  Created by Mco on 2018/3/31.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOMeDetails.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
#import "MCOSelfInfoVC.h"
#import "MCOSelfInfoModByDX.h"
#import <JMessage/JMessage.h>
@interface MCOMeDetails ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation MCOMeDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    
}

- (void)setupNavBar
{
    self.navigationItem.title = @"个人资料";
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
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"个人头像";
            cell.imageView.image = [UIImage imageNamed:@"login_13"];
            break;
        case 1:
            cell.textLabel.text = @"个人信息";
            cell.imageView.image = [UIImage imageNamed:@"login_02"];
            break;
        case 2:
            cell.textLabel.text = @"手机号";
            cell.imageView.image = [UIImage imageNamed:@"menu_16"];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *str = [defaults objectForKey:@"user_phone"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"                                                                  ***%@",[str substringFromIndex:7]];
            break;
    }

    //设置选中样式为null
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //向右箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//        NSLog(@"选中了%ld-%ld",indexPath.section,indexPath.row);
    switch (indexPath.row) {
        case 0://个人头像
        {
            //创建控制器
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择图片来源？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            //创建按钮
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openAlbum];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openCamera];
            }];
            UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            //添加按钮
            [alertVC addAction:action1];
            [alertVC addAction:action2];
            [alertVC addAction:action3];
            //显示弹框
            [self presentViewController:alertVC animated:YES completion:nil];
        }
            break;
        case 1://个人信息
        {
            MCOSelfInfoVC *vc = [[MCOSelfInfoVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2://手机号
        {
            MCOSelfInfoModByDX *vc = [[MCOSelfInfoModByDX alloc] init];
            vc.type = @"0";
            vc.zdm = @"user_phone";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
       
    }
}
//打开相册
-(void)openAlbum
{
    UIImagePickerController *picker =[[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
//打开照相机
-(void)openCamera
{
    UIImagePickerController *picker =[[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

//选取照片后
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    //关闭图片选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    [MBProgressHUD showMessage:@"上传中..." toView:self.navigationController.view];
    
    //上传图片到服务器
    [self uploadImage:info[UIImagePickerControllerOriginalImage]];
    
#pragma mark -im更新头像
    NSData *data = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.9f);
    [JMSGUser updateMyInfoWithParameter:data userFieldType:kJMSGUserFieldsAvatar completionHandler:^(id resultObject, NSError *error) {
//        if (!error) {
//            //updateMyInfoWithPareter success
//            NSLog(@"im update touxiang sucess");
//        } else {
//            //updateMyInfoWithPareter fail
//        }
    }];
//    NSLog(@"%@",info);
}


-(void)uploadImage:(UIImage *)image
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = @{@"user_id":[defaults objectForKey:@"user_phone"]};
    
    [manager POST:@"http://106.14.145.208/ShopMall/UpdateForUserPhoto" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(image, 0.9f);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
         if([resp isEqualToString:@"error"])
         {
             [MBProgressHUD hideHUDForView:self.navigationController.view];
             [MBProgressHUD showError:@"上传失败,请稍后再试" toView:self.navigationController.view];
         }
        else
        {
            //重写头像路径到偏好
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:resp forKey:@"user_touxiang"];
            //发送登录成功到主界面界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logSucuess" object:nil userInfo:nil];
            [MBProgressHUD hideHUDForView:self.navigationController.view];
            [MBProgressHUD showSuccess:@"上传成功" toView:self.navigationController.view];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.navigationController.view];
        [MBProgressHUD showError:@"上传失败,请稍后再试" toView:self.navigationController.view];
    }];
    
}


@end
