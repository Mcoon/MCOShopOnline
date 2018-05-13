//
//  MCOOrderAddressVC.m
//  MCOShopOnline
//
//  Created by Mco on 2018/5/1.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOOrderAddressVC.h"
#import "MCOShopOrder.h"
@interface MCOOrderAddressVC ()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;

@end

@implementation MCOOrderAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = @"收货地址";
    
    if([self.order.ord_status isEqualToString:@"8"])//自提
    {
        self.typeLabel.text = @"店铺自提";
    }
    else if([self.order.ord_status isEqualToString:@"1"])//派送
    {
        if(self.order.ord_expressname ==nil)//商家派送
        {
            self.typeLabel.text = @"商家派送";
        }
        else
        {
            self.typeLabel.text = @"快递派送";
            
        }
        self.nameLabel.text = self.order.rev_name;
        self.phoneLabel.text = self.order.rev_phone;
        self.addrLabel.text = self.order.rev_address;
    }
    else//完成的
    {
        if(self.order.ord_expressname ==nil && self.order.rev_address ==nil)
        {
            self.typeLabel.text = @"店铺自提";
        }
        else if(self.order.ord_expressname ==nil && self.order.rev_address !=nil)
        {
            self.typeLabel.text = @"商家派送";
            self.nameLabel.text = self.order.rev_name;
            self.phoneLabel.text = self.order.rev_phone;
            self.addrLabel.text = self.order.rev_address;
        }
        else if(self.order.ord_expressname !=nil && self.order.rev_address !=nil)
        {
            self.typeLabel.text = @"快递派送";
            self.nameLabel.text = self.order.rev_name;
            self.phoneLabel.text = self.order.rev_phone;
            self.addrLabel.text = self.order.rev_address;
        }
    }

    
    
    [self.addrLabel sizeToFit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
