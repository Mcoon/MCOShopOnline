//
//  ViewController.m
//  相片的选择
//
//  Created by xiaomage on 16/3/27.
//  Copyright © 2016年 小码哥. All rights reserved.
//
/*
 从相册中选择多张图片(图片数量 >= 2)
 1> AssetsLibrary框架 (选择界面需要开发者自己搭建)
 2> Photos框架 (选择界面需要开发者自己搭建)
 */

#import "ViewController.h"
#import <CTAssetsPickerController.h>

@interface ViewController () <CTAssetsPickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // photo  image picker asset
}

- (IBAction)selectPhoto {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 弹出图片选择界面
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            // 隐藏空相册
            picker.showsEmptyAlbums = NO;
            // 显示图片索引
            picker.showsSelectionIndex = YES;
            picker.assetCollectionSubtypes = @[
                                               @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                               @(PHAssetCollectionSubtypeAlbumRegular)
                                               ];
            picker.delegate = self;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // 如果当前运行的设备是平板电脑
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

#pragma mark - <CTAssetsPickerControllerDelegate>
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = 9;
    
    if (picker.selectedAssets.count < max) return YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注意"
                                        message:[NSString stringWithFormat:@"最多选择%zd张图片", max]
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    // 这里一定要用picker，不能使用self（因为当前显示在上面的控制器是picker，不是self）
    [picker presentViewController:alert animated:YES completion:nil];
    
    return NO;
}

/**
 *  选择完毕的时候调用
 */
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    // 关闭图片选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 选择图片时的配置项
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // 显示图片
    for (NSInteger i = 0; i < assets.count; i++) {
        PHAsset *asset = assets[i];
        CGSize size = CGSizeMake(asset.pixelWidth / [UIScreen mainScreen].scale, asset.pixelHeight / [UIScreen mainScreen].scale);
        
        // 请求图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            // 添加图片控件
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = result;
            [self.view addSubview:imageView];
            
            imageView.frame = CGRectMake((i % 3) * (100 + 10), (i / 3) * (100 + 10), 100, 100);
        }];
    }
}
@end
