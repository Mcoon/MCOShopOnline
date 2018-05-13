//
//  MCOCartPayViewController.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/28.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCOUserAddrItem;
@class MCOSelfOrder;
@interface MCOCartPayViewController : UIViewController

@property(nonatomic,strong)MCOUserAddrItem *address;
@property(nonatomic,strong)MCOSelfOrder *order;

/*
 '0': 店家配送
 '8'自提
 */
@property(nonatomic,strong)NSString *taketype;
@end
