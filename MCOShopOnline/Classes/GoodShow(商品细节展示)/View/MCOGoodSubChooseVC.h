//
//  MCOGoodSubChooseVC.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCOGoodDetailItem;
@interface MCOGoodSubChooseVC : UIViewController

@property (nonatomic,strong)MCOGoodDetailItem *item;
//随便写什么都隐藏加入购物车按钮
@property(nonatomic,strong)NSString *hideInsertCart;
@end
