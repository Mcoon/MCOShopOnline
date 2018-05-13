//
//  MCORefCell.h
//  MCOShopOnline
//
//  Created by Mco on 2018/5/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCORef;
@interface MCORefCell : UITableViewCell

@property(nonatomic,strong)MCORef *item;
@property(nonatomic,strong)NSString *type;
@end
