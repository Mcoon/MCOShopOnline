//
//  MCOExpressItem.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/26.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOExpressItem : NSObject
@property(nonatomic,strong)NSString *expressName;//快递名称
@property(nonatomic,strong)NSString *expressId;//快递单号
@property(nonatomic,strong)NSString *expressCode;//快递代码
@end
