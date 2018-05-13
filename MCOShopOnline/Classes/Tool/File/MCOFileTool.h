//
//  MCOFileTool.h
//  MCOShopOnline
//
//  Created by Mco on 2018/4/5.
//  Copyright © 2018年 Mco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOFileTool : NSObject

/**
 *  获取文件夹尺寸
 *
 *  @param directoryPath 文件夹路径
 *
 */
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger))completion;


/**
 *  删除文件夹所有文件
 *
 *  @param directoryPath 文件夹路径
 */
+ (void)removeDirectoryPath:(NSString *)directoryPath;

@end
