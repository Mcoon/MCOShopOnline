//
//  MCOCartCell.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCOCartItem;
@interface MCOCartCell : UITableViewCell

@property(nonatomic,strong)MCOCartItem *item;
@property(nonatomic,assign)NSInteger row;
@end
