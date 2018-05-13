//
//  MCOShopTrendItem.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/11.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOShopTrendItem : NSObject
/*
 obj.addProperty("shop_mster", rst.getString("shop_mster"));//店主id
 obj.addProperty("mster_name", rst.getString("user_name"));//店主名称
 obj.addProperty("mster_touxiang", rst.getString("user_touxiang"));//店主头像（可能为null）
 obj.addProperty("uptime", sdf.format(rst.getTimestamp("uptime")));//发布时间
 obj.addProperty("dyn_content", rst.getString("dyn_content"));//文字内容
 obj.addProperty("dyn_photots", rst.getString("dyn_photots"));//图片（可能为null）
 */

@property (nonatomic,strong)NSString *shop_mster;
@property (nonatomic,strong)NSString *mster_name;
@property (nonatomic,strong)NSString *mster_touxiang;
@property (nonatomic,strong)NSString *uptime;
@property (nonatomic,strong)NSString *dyn_content;
@property (nonatomic,strong)NSString *dyn_photots;
@end
