//
//  MCOCartCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOCartCell.h"
#import "MCOCartItem.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
@interface MCOCartCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *nowPrice;
@property (weak, nonatomic) IBOutlet UILabel *formLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLable;
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (weak, nonatomic) IBOutlet UIButton *minusBtn;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end

@implementation MCOCartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setItem:(MCOCartItem *)item
{
    _item = item;
    _name.text = [NSString stringWithFormat:@"[%@] %@",item.pro_brand,item.pro_name];
    float discount = [item.pro_discount floatValue];
    float nowPrice = [item.pro_price floatValue] * discount;
    NSString *price = [NSString stringWithFormat:@"%0.1f",nowPrice];
    _nowPrice.text = [NSString stringWithFormat:@"¥%@",price];
    NSString *sizestr = item.pro_size;
    NSString *colorstr = item.pro_color;
    _formLabel.text = [NSString stringWithFormat:@"%@,%@",sizestr,colorstr];
    
    _numLabel.text = [NSString stringWithFormat:@"%ld",item.pro_num];
    
    NSString *urlstr = [NSString stringWithFormat:@"http://106.14.145.208%@",item.pro_photo];
    [_iconView sd_setImageWithURL:[NSURL URLWithString:urlstr]];
}

- (IBAction)plusClick {
    _item.pro_num++;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",_item.pro_num];
    self.minusBtn.enabled = YES;
    //请求删除数据库信息
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"pro_id":[defaults objectForKey:@"user_phone"],@"good_id":_item.pro_id,@"good_num":[NSString stringWithFormat:@"%ld",_item.pro_num],@"good_size":_item.pro_size,@"good_color":_item.pro_color};
    
    [mgr POST:@"http://106.14.145.208/ShopMall/UpdateUserCartInfo" parameters:dict progress:nil success:nil failure:nil];
}
- (IBAction)minusClick {
    
    if(_item.pro_num ==1) return;
        
    _item.pro_num --;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",_item.pro_num];
    //请求删除数据库信息
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //支持text/html
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //resp内容为非json处理方法
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict =@{@"pro_id":[defaults objectForKey:@"user_phone"],@"good_id":_item.pro_id,@"good_num":[NSString stringWithFormat:@"%ld",_item.pro_num],@"good_size":_item.pro_size,@"good_color":_item.pro_color};
    
    [mgr POST:@"http://106.14.145.208/ShopMall/UpdateUserCartInfo" parameters:dict progress:nil success:nil failure:nil];
    
    if(_item.pro_num == 0)
    {
        self.minusBtn.enabled = NO;
    }
}

@end
