//
//  MCOTextTool.m
//  MCOShopOnline
//
//  Created by Mco on 2018/4/11.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import "MCOTextTool.h"
#import <UIKit/UIKit.h>
@implementation MCOTextTool

//根据内容计算宽度 计算宽度时要确定高度、字号
+ (CGFloat)calculateRowWidth:(NSString *)string fontSize:(NSInteger)fontSize withHeight:(NSInteger)fontHeight{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};  //指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, fontHeight)/*计算宽度时要确定高度*/ options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
}

//根据内容计算高度 计算高度要先指定宽度、字号
+ (CGFloat)calculateRowHeight:(NSString *)string fontSize:(NSInteger)fontSize withWidth:(NSInteger)fontWidth{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};//指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(fontWidth, 0)/*计算高度要先指定宽度*/ options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.height;
}

+(NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}
@end
