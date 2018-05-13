//
//  MCOTextColor.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/7.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MCOTextColor : NSObject
+(void)LabelAttributedString:(UILabel*)label firstW:(NSString *)oneW toSecondW:(NSString *)twoW color:(UIColor *)color size:(CGFloat)size;
@end
