//
//  MCOUserAddrItem.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/28.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOUserAddrItem : NSObject
/*
 rev_name nvarchar(200) not null,
 rev_phone nvarchar(11) not null,
 rev_address nvarchar(500) not null
 */
@property(nonatomic,strong)NSString *rev_name;
@property(nonatomic,strong)NSString *rev_phone;
@property(nonatomic,strong)NSString *rev_address;

@end
