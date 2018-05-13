//
//  MCOShopGoodItem.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/4.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOShopGoodItem : NSObject
/*
 obj.addProperty("pro_id", String.valueOf(rst.getInt("pro_id")));//商品ID
 obj.addProperty("pro_name", rst.getString("pro_name"));//商品名称
 obj.addProperty("pro_brand", rst.getString("pro_brand"));//名牌
 obj.addProperty("pro_price", String.valueOf(rst.getFloat("pro_price")));//商品原价
 obj.addProperty("pro_discount", String.valueOf(rst.getFloat("pro_discount")));//商品折扣
 obj.addProperty("pro_photo", rst.getString("pro_photo").split(";")[0]);//商品展示图片
 */
@property (nonatomic, strong) NSString *pro_id;
@property (nonatomic, strong) NSString *pro_name;
@property (nonatomic, strong) NSString *pro_brand;
@property (nonatomic, strong) NSString *pro_price;
@property (nonatomic, strong) NSString *pro_discount;
@property (nonatomic, strong) NSString *pro_photo;
@end
