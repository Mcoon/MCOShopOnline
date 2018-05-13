//
//  MCOGood.m
//  MCO电商
//
//  Created by Mco on 2018/4/1.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGood.h"
@interface MCOGood()
/*名称*/
@property (nonatomic,strong) NSString *name;
/*分类*/
@property (nonatomic,assign) NSInteger classify;
/*使用人群*/
@property (nonatomic,strong) NSString *suitperson;
/*主材料*/
@property (nonatomic,strong) NSString *material;
/*品牌*/
@property (nonatomic,strong) NSString *brand;
/*包含尺寸*/
@property (nonatomic,strong) NSArray *sizeArr;
/*包含颜色*/
@property (nonatomic,strong) NSArray *colorArr;
/*总价*/
@property (nonatomic,strong) NSString *price;
/*打折率*/
@property (nonatomic,strong) NSString *count;
/*产品说明*/
@property (nonatomic,strong) NSString *descripe;
/*产品图片*/
@property (nonatomic,strong) NSArray *imageArr;
/*产品宣传图片*/
@property (nonatomic,strong) NSArray *descimageArr;

@end

@implementation MCOGood

-(void)setName:(NSString *)name
{
    
}

@end
