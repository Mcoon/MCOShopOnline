//
//  MCOGoodNumCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodNumCell.h"
@interface MCOGoodNumCell()
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (weak, nonatomic) IBOutlet UIButton *minusBtn;

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (assign,nonatomic) NSUInteger num;
@end



@implementation MCOGoodNumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _num = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)plusClick {
    _num ++;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)_num];
    self.minusBtn.enabled = YES;
    
}
- (IBAction)minusClick {
    _num --;
    self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)_num];
    if(_num == 0)
    {
        self.minusBtn.enabled = NO;
    }
}

-(NSUInteger)backSelectedNum
{
    return _num;
}

@end
