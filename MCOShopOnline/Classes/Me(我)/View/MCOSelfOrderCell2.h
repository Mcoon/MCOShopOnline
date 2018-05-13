//
//  MCOSelfOrderCell2.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/15.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCOSelfOrder;
@interface MCOSelfOrderCell2 : UITableViewCell

@property(nonatomic,strong)MCOSelfOrder *order;
@property(nonatomic,strong)NSString *extra;
@end
