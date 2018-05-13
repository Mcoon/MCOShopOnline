//
//  MCOGoodSelectCell.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCOGoodSelectCell : UITableViewCell

@property(nonatomic,strong)NSString *proityName;
@property(nonatomic,strong)NSString *selectValues;
-(NSString *)backSelectedValue;
@end
