//
//  MCOSquareCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/4.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOSquareCell.h"
#import "MCOSquareItem.h"

@interface MCOSquareCell()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation MCOSquareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setItem:(MCOSquareItem *)item
{
    _item = item;
    _icon.image = item.icon;
    _name.text = item.name;
}

@end
