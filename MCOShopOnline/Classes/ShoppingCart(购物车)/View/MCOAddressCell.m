//
//  MCOAddressCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/28.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOAddressCell.h"
#import "MCOUserAddrItem.h"

@interface MCOAddressCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;

@end

@implementation MCOAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)setAddress:(MCOUserAddrItem *)address
{
    _address = address;
    self.nameLabel.text = address.rev_name;
    self.phoneLabel.text = address.rev_phone;
    self.addrLabel.text = address.rev_address;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
