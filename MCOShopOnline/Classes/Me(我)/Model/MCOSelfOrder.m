//
//  MCOSelfOrder.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/14.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSelfOrder.h"
#import "MJExtension.h"
#import "MCOSelfOrderItem.h"
@implementation MCOSelfOrder

+(NSDictionary *)mj_objectClassInArray
{
    return @{@"ord_products":[MCOSelfOrderItem class]};
}

@end
