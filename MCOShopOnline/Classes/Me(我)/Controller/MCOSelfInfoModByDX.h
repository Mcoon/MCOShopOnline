//
//  MCOSelfInfoModByDX.h
//  MCOShopOnline
//
//  Created by Mco on 2018/5/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCOSelfInfoModByDX : UIViewController

/*
 ‘0’；更该手机号
 '1':忘记密码
 */
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *zdm;
@end
