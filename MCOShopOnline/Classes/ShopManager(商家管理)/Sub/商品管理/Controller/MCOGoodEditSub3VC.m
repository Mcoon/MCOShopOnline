//
//  MCOGoodEditSub3VC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/25.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodEditSub3VC.h"
#import "TZImagePickerController.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
#import "MCOGoodDetailItem.h"
@interface MCOGoodEditSub3VC ()<TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *photoViewArea;
@property (strong,nonatomic)NSMutableArray *photoArr;
@property (nonatomic, weak) AFHTTPSessionManager *mgr;
@end

@implementation MCOGoodEditSub3VC

-(NSMutableArray *)photoArr
{
    if(_photoArr == nil)
    {
        _photoArr = [NSMutableArray array];
    }
    return _photoArr;
}

-(void)setType:(NSString *)type
{
    _type = type;
    if([type isEqualToString:@"0"])
    {
        self.navigationItem.title = @"产品图片";
    }
    else
    {
        self.navigationItem.title = @"产品宣传图片";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //右上角完成
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(complete)];
    
}

- (IBAction)selectPhoto {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.preferredLanguage = @"zh-Hans";
    //    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
    ////        NSLog(@"%@",coverImage);
    //    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    //去除view所有子控件
    for(UIView *view in [self.photoViewArea subviews])
    {
        [view removeFromSuperview];
    }
    self.photoArr = photos;
    NSInteger margin = ([UIScreen mainScreen].bounds.size.width - 100 * 3 - 40) / 2;
    for (int i = 0; i<photos.count; i++) {
        UIImageView *image = [[UIImageView alloc] init];
        image.image = photos[i];
        image.frame = CGRectMake(margin+(i % 3) * 120, (i / 3) * 120, 100, 100);
        [self.photoViewArea addSubview:image];
    }
    
}

-(void)complete
{
    if(self.photoArr.count == 0)
    {
        [MBProgressHUD showError:@"至少要选择一张图片"];
    }
    else
    {
        
        [MBProgressHUD showMessage:@"商品资料上传中，请稍等.."];
        [self upload];
    }
    
}

-(void)upload
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    _mgr = manager;
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict =@{@"pro_id":self.good.pro_id,@"type":self.type};
    //formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
    [manager POST:@"http://106.14.145.208/ShopMall/ModifyGoodXCPhoto" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //上传图片
        for (int i = 0; i < self.photoArr.count; i++) {
            
            UIImage *image = self.photoArr[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
            
            // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
            // 要解决此问题，
            // 可以在上传时使用当前的系统事件作为文件名
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString  stringWithFormat:@"%@.png", dateString];
            /*
             *该方法的参数
             1. appendPartWithFileData：要上传的照片[二进制流]
             2. name：对应网站上[upload.php中]处理文件的字段（比如upload）
             3. fileName：要保存在服务器上的文件名
             4. mimeType：上传的文件的类型
             */
            [formData appendPartWithFileData:imageData name:@"photos" fileName:fileName mimeType:@"image/png"]; //
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [MBProgressHUD hideHUD];
        
        if([resp isEqualToString:@"error"])
        {
            [MBProgressHUD showError:@"网络错误，请重试！"];
        }
        else
        {
            
            [MBProgressHUD showSuccess:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误，请重试！"];
    }];
}

//界面即将消失时，取消请求任务
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_mgr.tasks makeObjectsPerformSelector:@selector(cancel)];
}
@end
