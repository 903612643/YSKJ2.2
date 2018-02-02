//
//  DBHelper.m
//  YSKJ
//
//  Created by YSKJ on 17/5/9.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_DBHelper.h"

static NSString * const DB_NAME_PRO = @"YSKJ_Pro_DataBase";  //数据库名

@implementation YSKJ_DBHelper

+(YSKJ_DBHelper *)sharedHelper{
    static YSKJ_DBHelper *instance = nil;
    static dispatch_once_t onceToken;
    if (!instance) {
        dispatch_once(&onceToken, ^{
            instance = [[super allocWithZone:nil]init];
        });
    }
    return instance;
}

-(FMDatabaseQueue *)dbQueue{
    if (!_dbQueue) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[self class] dbPath]];
    }
    return _dbQueue;
}

//数据库地址
+ (NSString *)dbPath
{
    // 获取 APP 沙盒路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *uidPath = [NSString stringWithFormat:@"%@/%@", docPath, @"YSKJ_DB"];
    NSString *dbPath  = [NSString stringWithFormat:@"%@/%@.sqlite",uidPath ,DB_NAME_PRO];
    
    return dbPath;
}

#pragma --mark 保证单例不会被创建成新对象
+(instancetype)alloc{
    NSAssert(0, @"这是一个单例对象，请使用+(YSKJ_DBHelper *)sharedHelper方法");
    return nil;
}
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [YSKJ_DBHelper sharedHelper];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [YSKJ_DBHelper sharedHelper];
}

@end
