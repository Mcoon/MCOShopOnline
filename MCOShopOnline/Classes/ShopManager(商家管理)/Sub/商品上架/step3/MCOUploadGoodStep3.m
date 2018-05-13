//
//  MCOUploadGoodStep3.m
//  MCO电商
//
//  Created by Mco on 2018/4/2.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOUploadGoodStep3.h"
#import "MCOSizeTextField.h"
#import "MBProgressHUD+XMG.h"
#import "MCOGoodPickerVC.h"
@interface MCOUploadGoodStep3 ()

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet MCOSizeTextField *sizeTF;

@property (strong,nonatomic) NSMutableArray *sizeArr;

@end

@implementation MCOUploadGoodStep3

-(NSMutableArray *)sizeArr
{
    if(_sizeArr == nil)
    {
        _sizeArr = [NSMutableArray array];
    }
    return _sizeArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)continueAdd {
    if(self.sizeTF.text.length == 0)
    {
        [MBProgressHUD showError:@"不可添加空内容"];
        return;
    }
    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@添加成功",self.sizeTF.text]];
    if(self.sizeLabel.text.length == 0)
    {
        self.sizeLabel.text =[NSString stringWithFormat:@"已添加：%@",self.sizeTF.text];
    }
    else
    {
        self.sizeLabel.text = [NSString stringWithFormat:@"%@,%@",self.sizeLabel.text,self.sizeTF.text];
    }
    
    [self.sizeArr addObject:self.sizeTF.text];
    self.sizeTF.text = @"";
}
- (IBAction)clearSize {
    [self.sizeArr removeAllObjects];
    self.sizeTF.text = @"";
    self.sizeLabel.text = @"";
}
- (IBAction)completeAdd {
    if(self.sizeArr.count>0)
    {
        [self.good setValue:self.sizeArr forKey:@"pro_size"];
        
        MCOGoodPickerVC *vc = [[MCOGoodPickerVC alloc] init];
        vc.good = self.good;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [MBProgressHUD showError:@"至少选择一项"];
    }
    
}

@end
