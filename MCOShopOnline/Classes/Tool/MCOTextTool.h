//
//  MCOTextTool.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/11.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MCOTextTool : NSObject

//根据内容计算宽度 计算宽度时要确定高度、字号
+(CGFloat)calculateRowWidth:(NSString *)string fontSize:(NSInteger)fontSize withHeight:(NSInteger)fontHeight;

//根据内容计算高度 计算高度要先指定宽度、字号
+(CGFloat)calculateRowHeight:(NSString *)string fontSize:(NSInteger)fontSize withWidth:(NSInteger)fontWidth;
//将汉字转成拼音
+(NSString *)transform:(NSString *)chinese;

@end
