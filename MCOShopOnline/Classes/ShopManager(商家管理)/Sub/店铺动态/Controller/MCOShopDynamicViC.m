//
//  MCOShopDynamicViC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/10.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOShopDynamicViC.h"
#import "TZImagePickerController.h"
#import "MBProgressHUD+XMG.h"
#import "AFNetworking.h"
@interface MCOShopDynamicViC ()
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UITextView *textContent;
@property (weak, nonatomic) IBOutlet UIScrollView *photoArea;
@property (strong,nonatomic)NSMutableArray *photoArr;
@end

@implementation MCOShopDynamicViC

-(NSMutableArray *)photoArr
{
    if(_photoArr == nil)
    {
        _photoArr = [NSMutableArray array];
    }
    return _photoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    self.selectBtn.layer.cornerRadius = 10;
    //右上角完成
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(complete)];
}

- (void)setupNavBar
{
    
    self.navigationItem.title = @"发布动态";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)complete
{
    if(self.textContent.text.length == 0)
    {
        [MBProgressHUD showError:@"文字内容不能为空"];
    }
    else
    {
        
        [MBProgressHUD showMessage:@"正在发布动态.."];
        [self upload];
    }
    
}

-(void)upload
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = @{@"mat_phone":[defaults objectForKey:@"user_phone"],@"content":self.textContent.text};
    //formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
    [manager POST:@"http://106.14.145.208/ShopMall/UploadShopDynamic" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if(self.photoArr.count>0)
        {
            //上传店铺宣传图片
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
                [formData appendPartWithFileData:imageData name:@"imge" fileName:fileName mimeType:@"image/png"]; //
            }
        }
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSLog(@"上传成功 %@", responseObject);
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"上传成功"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //        NSLog(@"上传失败 %@", error);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"上传失败"];
    }];
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
    for(UIView *view in [self.photoArea subviews])
    {
        [view removeFromSuperview];
    }
    self.photoArr = photos;
    for (int i = 0; i<photos.count; i++) {
        UIImageView *image = [[UIImageView alloc] init];
        image.image = photos[i];
        image.frame = CGRectMake((i % 3) * 125, (i / 3) * 125, 100, 100);
        [self.photoArea addSubview:image];
    }
    
}




@end
