//
//  MCOSelfOrderItemView.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/14.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCOSelfOrderItem;
@interface MCOSelfOrderItemView : UIView
@property (nonatomic,strong)MCOSelfOrderItem *item;

+(instancetype)fastView;

@end
