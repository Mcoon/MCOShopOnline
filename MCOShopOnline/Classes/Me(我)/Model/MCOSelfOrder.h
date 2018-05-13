//
//  MCOSelfOrder.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/14.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOSelfOrder : NSObject
/*
 obj.addProperty("ord_id",ord_id);
 obj.addProperty("ord_time",rst.getString("ord_time"));
 obj.addProperty("ord_money",String.valueOf(rst.getFloat("ord_money")));
 obj.addProperty("ord_products", array2.toString());
 obj.addProperty("ord_status",rst.getString("ord_status"));
 obj.addProperty("ord_expressname",rst.getString("ord_expressname"));
 obj.addProperty("ord_expressid",rst.getString("ord_expressid"));
 obj.addProperty("rev_name", rst.getString("rev_name"));
 obj.addProperty("rev_phone", rst.getString("rev_phone"));
 obj.addProperty("rev_address", rst.getString("rev_address"));
 */
@property (nonatomic,strong) NSString *ord_id;
@property (nonatomic,strong) NSString *ord_time;
@property (nonatomic,strong) NSString *ord_money;
@property (nonatomic,strong) NSArray *ord_products;
@property (nonatomic,strong) NSString *ord_status;
@property (nonatomic,strong) NSString *ord_expressname;
@property (nonatomic,strong) NSString *ord_expressid;
@property (nonatomic,strong) NSString *rev_name;
@property (nonatomic,strong) NSString *rev_phone;
@property (nonatomic,strong) NSString *rev_address;
@end
