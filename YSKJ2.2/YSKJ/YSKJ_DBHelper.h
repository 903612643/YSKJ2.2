//
//  DBHelper.h
//  YSKJ
//
//  Created by YSKJ on 17/5/9.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface YSKJ_DBHelper : NSObject

@property (nonatomic, retain) FMDatabaseQueue *dbQueue;

/**
 *  获取数据库管理类单例
 */
+(YSKJ_DBHelper *)sharedHelper;

/**
 *  数据库文件沙盒地址
 */
+ (NSString *)dbPath;


@end
