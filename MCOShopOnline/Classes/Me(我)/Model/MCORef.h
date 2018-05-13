//
//  MCORef.h
//  MCOShopOnline
//
//  Created by Mco on 2018/5/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCORef : NSObject
/*
 ref_id int auto_increment primary key,
 ref_user nvarchar(11) not null,
 ref_zfbid nvarchar(50) not null,
 ref_time timestamp not null,
 ref_money nvarchar(200) not null,
 ref_status nvarchar(1) default'0'
 */
@property(nonatomic,strong)NSString *ref_id;
@property(nonatomic,strong)NSString *ref_user;
@property(nonatomic,strong)NSString *ref_zfbid;
@property(nonatomic,strong)NSString *ref_time;
@property(nonatomic,strong)NSString *ref_status;
@property(nonatomic,strong)NSString *ref_money;
@end
