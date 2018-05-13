//
//  MCOTableViewCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/6.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTableViewCell.h"
@interface MCOTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation MCOTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

-(void)setName:(NSString *)name
{
    _name = name;
    _nameLabel.text = name;
}

-(void)setValue:(NSString *)value
{
    _value = value;
    _valueLabel.text = value;
}


@end
