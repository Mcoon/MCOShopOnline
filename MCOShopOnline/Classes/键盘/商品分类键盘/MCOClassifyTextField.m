//
//  MCOClassifyTextField.m
//  MCO电商
//
//  Created by Mco on 2018/4/1.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOClassifyTextField.h"
#import "AFNetworking.h"
@interface MCOClassifyTextField() <UIPickerViewDelegate,UIPickerViewDataSource>

//数据数组
@property (nonatomic,strong) NSArray *arrayData;

@end

@implementation MCOClassifyTextField

//初始化
-(void)awakeFromNib
{
    [self getClassify];
    [self setUp];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self getClassify];
        [self setUp];
    }
    return self;
}

-(void)getClassify
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //resp内容为非json处理方法
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"http://106.14.145.208/ShopMall/BackAppClassify" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resp = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(![resp isEqualToString:@"error"])
        {
            if(resp.length>0)
            {
                NSArray *array = [resp componentsSeparatedByString:@","];
                self.arrayData = array;
                self.text = array[0];
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//初始化函数
-(void)setUp
{
    //创建pickview
    UIPickerView *pickView = [[UIPickerView alloc] init];
    //设置代理
    pickView.delegate = self;
    //设置数据源
    pickView.dataSource = self;
    //让弹出的键盘是一个uipickview
    self.inputView = pickView ;
}

// 返回多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// 返回多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayData.count-1;
}

//每一行显示的内容
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.arrayData[row];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//每一行高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 80;
}

//选中事件
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.text = self.arrayData[row];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width,44)];
    /*
     Toolbar 在iOS11默认添加有_UIToolbarContentView，_UIToolbarContentView_UIButtonBarStackView覆盖在自定义的按钮上面，导致按钮无响应。
     解决办法：调用 layoutIfNeeded方法，UIToolbarContentView会降低到UIToolBar的第一个子视图，然后你就可以将所有的子视图添加到最顶层。
     */
    [bar layoutIfNeeded];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 7,50, 30)];
    
    [button setTitle:@"完成"forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    button.layer.borderColor = [UIColor grayColor].CGColor;
    
    button.layer.borderWidth =1;
    
    button.layer.cornerRadius =3;
    
    
    
    [bar addSubview:button];
    
    self.inputAccessoryView = bar;
    
    [button addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)complete
{
    [self endEditing:YES];
}



@end
