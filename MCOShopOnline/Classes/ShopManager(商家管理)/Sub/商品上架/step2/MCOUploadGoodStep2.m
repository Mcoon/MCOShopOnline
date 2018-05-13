//
//  MCOUploadGoodStep2.m
//  MCO电商
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOUploadGoodStep2.h"
#import "MCOColor.h"
#import "MBProgressHUD+XMG.h"
#import "MCOUploadGoodStep3.h"
@interface MCOUploadGoodStep2 ()

@property (strong,nonatomic) NSMutableArray *colorArr;

@property (weak, nonatomic) IBOutlet MCOColor *colorTF;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;

@end



@implementation MCOUploadGoodStep2

-(NSMutableArray *)colorArr
{
    if(_colorArr == nil)
    {
        _colorArr = [NSMutableArray array];
    }
    return _colorArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearColor {
    [self.colorArr removeAllObjects];
    self.colorTF.text = @"";
    self.colorLabel.text = @"";
}

- (IBAction)continueAdd {
    if(self.colorTF.text.length == 0)
    {
        [MBProgressHUD showError:@"不可添加空内容"];
        return;
    }
    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@添加成功",self.colorTF.text]];
    if(self.colorLabel.text.length == 0)
    {
        self.colorLabel.text =[NSString stringWithFormat:@"已添加：%@",self.colorTF.text];
    }
    else
    {
        self.colorLabel.text = [NSString stringWithFormat:@"%@,%@",self.colorLabel.text,self.colorTF.text];
    }
    
    [self.colorArr addObject:self.colorTF.text];
    self.colorTF.text = @"";
}
- (IBAction)completeAdd {
    if(self.colorArr.count>0)
    {
    [self.good setValue:self.colorArr forKey:@"pro_color"];
    
    MCOUploadGoodStep3 *vc = [[MCOUploadGoodStep3 alloc] init];
    vc.good = self.good;
    [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [MBProgressHUD showError:@"至少选择一项"];
    }
    
}

@end
