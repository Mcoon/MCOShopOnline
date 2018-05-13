//
//  MCOShopOrder.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/16.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOShopOrder.h"
#import "MJExtension.h"
#import "MCOSelfOrderItem.h"
@implementation MCOShopOrder
+(NSDictionary *)mj_objectClassInArray
{
    return @{@"ord_products":[MCOSelfOrderItem class]};
}
@end
