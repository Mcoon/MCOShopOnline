//
//  MCORefCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCORefCell.h"
#import "MCORef.h"
#import "AFNetworking.h"
#import "MBProgressHUD+XMG.h"
@interface MCORefCell()
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *zfb;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *money;

@end

@implementation MCORefCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if([self.type isEqualToString:@"0"])
    {
        self.confirmBtn.hidden = YES;
    }
    else
    {
        self.confirmBtn.hidden = NO;
    }
}

-(void)setItem:(MCORef *)item
{
    _item = item;
    self.phone.text = item.ref_user;
    self.zfb.text = item.ref_zfbid;
    self.time.text = item.ref_time;
    self.money.text = item.ref_money;
    if([item.ref_status isEqualToString:@"0"])
    {
        self.status.text = @"提现中";
        self.status.textColor = [UIColor redColor];
    }
    else
    {
        self.status.text = @"已提现";
        self.status.textColor = [UIColor greenColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)confirm {
    [MBProgressHUD showMessage:@"确认中..."];
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *dict =@{@"ref_id":self.item.ref_id};
    [mgr POST:@"http://106.14.145.208/ShopMall/UpdateReflectStatus" parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if([resp isEqual:@"error"])
        {
            [MBProgressHUD showError:@"网络失败，请稍后再试！"];
        }
        else
        {
            [MBProgressHUD showSuccess:@"确认成功"];
            [self.confirmBtn setTitle:@"已确认" forState:UIControlStateNormal];
            self.status.text = @"已提现";
            self.confirmBtn.enabled = NO;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络失败，请稍后再试！"];
        
    }];
}

@end
