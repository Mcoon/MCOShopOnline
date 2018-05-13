//
//  MCOGoodSelectCell.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/8.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOGoodSelectCell.h"

@interface MCOGoodSelectCell()
@property (weak, nonatomic) IBOutlet UILabel *protyLabel;
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (strong,nonatomic) NSArray *dataArr;
@property (strong,nonatomic) NSString *selectedValue;
@property (strong,nonatomic) UIButton *lastBtn;
@end

@implementation MCOGoodSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setProityName:(NSString *)proityName
{
    _proityName = proityName;
    _protyLabel.text = proityName;
}
-(void)setSelectValues:(NSString *)selectValues
{
    _selectValues =selectValues;
    _dataArr = [selectValues componentsSeparatedByString:@","];
    CGFloat width = 70;
    CGFloat height = 26;
    CGFloat margin = 5;
    NSInteger contW = [UIScreen mainScreen].bounds.size.width / (width+margin);
    for (int i = 0; i < _dataArr.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:_dataArr[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(10+(i%contW) * (width+margin), (i/contW) * (height+margin), width, height);
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.layer.cornerRadius = 12;
        [btn addTarget:self action:@selector(selectValue:) forControlEvents:UIControlEventTouchUpInside];
        [_selectView addSubview:btn];
    }
}
-(void)selectValue:(UIButton *)btn
{
    _lastBtn.selected = NO;
    _lastBtn.backgroundColor = [UIColor lightGrayColor];
    _selectedValue = btn.titleLabel.text;
    btn.backgroundColor = [UIColor orangeColor];
    _lastBtn = btn;
}

//返回选中的值
-(NSString *)backSelectedValue
{
    return _selectedValue;
}

@end
