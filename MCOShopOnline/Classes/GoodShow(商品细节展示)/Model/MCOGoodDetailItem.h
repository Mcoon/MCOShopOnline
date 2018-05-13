//
//  MCOGoodDetailItem.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOGoodDetailItem : NSObject
/*
obj.addProperty("pro_id", String.valueOf(rst.getInt("pro_id")));//商品ID
obj.addProperty("pro_name", rst.getString("pro_name"));//商品名称
obj.addProperty("pro_classify", rst.getString("pro_classify"));//商品分类
obj.addProperty("pro_suitperson", rst.getString("pro_suitperson"));//适用人群
obj.addProperty("pro_material", rst.getString("pro_material"));//主要材料
obj.addProperty("pro_brand", rst.getString("pro_brand"));//名牌
obj.addProperty("pro_size", rst.getString("pro_size"));//尺寸
obj.addProperty("pro_color", rst.getString("pro_color"));//颜色
obj.addProperty("pro_price", String.valueOf(rst.getFloat("pro_price")));//商品原价
obj.addProperty("pro_discount", String.valueOf(rst.getFloat("pro_discount")));//商品折扣
obj.addProperty("pro_describe", rst.getString("pro_describe"));//商品描述
obj.addProperty("pro_photo", rst.getString("pro_photo"));//商品图片
obj.addProperty("pro_describephoto", rst.getString("pro_describephoto"));//商品宣传图片
obj.addProperty("pro_jfvalue", String.valueOf(rst.getInt("pro_jfvalue")));//商品积分值
*/

@property (nonatomic, strong) NSString *pro_id;
@property (nonatomic, strong) NSString *pro_name;
@property (nonatomic, strong) NSString *pro_classify;
@property (nonatomic, strong) NSString *pro_suitperson;
@property (nonatomic, strong) NSString *pro_material;
@property (nonatomic, strong) NSString *pro_brand;
@property (nonatomic, strong) NSString *pro_size;
@property (nonatomic, strong) NSString *pro_color;
@property (nonatomic, strong) NSString *pro_price;
@property (nonatomic, strong) NSString *pro_discount;
@property (nonatomic, strong) NSString *pro_describe;
@property (nonatomic, strong) NSString *pro_photo;
@property (nonatomic, strong) NSString *pro_describephoto;
@property (nonatomic, strong) NSString *pro_jfvalue;

@end
