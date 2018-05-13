//
//  MCOSelfOrderItem.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/14.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOSelfOrderItem : NSObject
/*
 obj2.addProperty("ord_gooid",String.valueOf(rst2.getInt("ord_gooid")));
 obj2.addProperty("ord_name",rst2.getString("pro_name"));
 obj2.addProperty("pro_price",String.valueOf(rst2.getFloat("pro_price")));
 obj2.addProperty("pro_discount",String.valueOf(rst2.getFloat("pro_discount")));
 obj2.addProperty("ord_photo",rst2.getString("pro_photo").split(";")[0]);
 obj2.addProperty("ord_size",rst2.getString("ord_size"));
 obj2.addProperty("ord_color",rst2.getString("ord_color"));
 obj2.addProperty("ord_num",String.valueOf(rst2.getInt("ord_num")));
 */
@property(nonatomic,strong)NSString *ord_gooid;
@property(nonatomic,strong)NSString *ord_name;
@property(nonatomic,strong)NSString *pro_price;
@property(nonatomic,strong)NSString *pro_discount;
@property(nonatomic,strong)NSString *ord_photo;
@property(nonatomic,strong)NSString *ord_size;
@property(nonatomic,strong)NSString *ord_color;
@property(nonatomic,strong)NSString *ord_num;
@end
