//  DatabaseManager.m
//  YSKJ
//
//  Created by YSKJ on 16/11/29.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "DatabaseManager.h"
#import "YSKJ_DBHelper.h"

@interface DatabaseManager() {
    FMDatabase *database;
}

@end

@implementation DatabaseManager


#pragma mark Create/Open/Close Database


- (void)openDatabaseWithAccount{
    
    // 获取 APP 沙盒路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *uidPath = [NSString stringWithFormat:@"%@/%@", docPath, Folder_DB];
    NSString *dbPath  = [NSString stringWithFormat:@"%@/%@.sqlite", uidPath, DB_NAME_PRO];
    
    NSLog(@"dbPath=%@",dbPath);
    
    // 检测路径是否存在, 如果不存在则创建路径
    if ([[NSFileManager defaultManager] fileExistsAtPath:uidPath] == false) {
        [[NSFileManager defaultManager] createDirectoryAtPath:uidPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    
    database = [FMDatabase databaseWithPath:dbPath];
    
    if (![database open]) {
        return;
    }
    
}

/** 打开数据库 */
- (void)openDatabase{
    
    [self openDatabaseWithAccount];
    
}

/** 关闭数据库 */
- (void)closeDatabase {
    [database close];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Check Table In Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 检测是否存在表 */
- (BOOL)isTableExsit:(NSString *)name {
    
    FMResultSet *rs = [database executeQuery:@"SELECT COUNT(*) FROM sqlite_master WHERE type ='table' AND name = ?", name];
    if ([rs next]) {
        if ([rs intForColumnIndex:0] > 0) {
            return true;
        }
    }
    [rs close];
    return false;
}

/** 获取当前表总数 */
- (int)getTableNumber {
    
    FMResultSet *rs = [database executeQuery:@"SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' "];
    [rs next];
    int num = [rs intForColumnIndex:0];
    [rs close];
    return num;
}

/** 获取表中记录数 */
- (int)getRecordNumber:(NSString *)tableName {
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", tableName];
    FMResultSet *rs = [database executeQuery:sqlstr];
    [rs next];
    int num = [rs intForColumnIndex:0];
    [rs close];
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(numData:withDatabaseMan:)]) {
        [self.delegate numData:num withDatabaseMan:self];
    }
    return num;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update Database

- (void)addDataToTableCurrentTableName:(NSString *)tableName  thumb_file:(NSString *)thumb_file desc_img:(NSString *)desc_img desc_model:(NSString *)desc_model product_id:(NSString *)product_id lastTime:(int)lastTime{
    
        // 如果不存在表名, 则创建表
        if ([self isTableExsit:tableName] == false) {
            
            NSString *sqlstr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@,%@,%@,%@,%@,%@,%@,%@)",
                                tableName,
                                @"ID integer PRIMARY KEY AUTOINCREMENT NOT NULL",
                                KEY_TABLE_CREATE_UTC,
                                KEY_TABLE_CREATE_DATE,
                                KEY_TABLE_CREATE_THU,
                                KEY_TABLE_CREATE_DES,
                                KEY_TABLE_CREATE_MOD,
                                KEY_TABLE_CREATE_SHOPID,
                                KEY_TABLE_CREATE_LASTTIME
                                ];
            [database executeUpdate:sqlstr];
            
            NSLog(@"FMDB_正在建表: %@",tableName);
        }

        NSDate *date=[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy_MM_dd HH:mm:ss";
        NSString *dateStr = [formatter stringFromDate:date];
        
        YSKJ_DBHelper *dbHelper = [YSKJ_DBHelper sharedHelper];
        [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
            
            NSString *sqlstr = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?,?)",
                                tableName,
                                KEY_DATA_UTC,
                                KEY_DATA_DATE,
                                KEY_DATA_THU,
                                KEY_DATA_DES,
                                KEY_DATA_MOD,
                                KEY_DATA_SHOPID,
                                KEY_DATA_LASTTIME
                                ];
            [database executeUpdate:sqlstr,
             [NSNumber numberWithInt:0],
             dateStr,
             thumb_file,
             desc_img,
             desc_model,
             product_id,
             [NSNumber numberWithInt:lastTime]
             ];
            
            NSLog(@"FMDB_插入新数据成功!");
        }];

    
}
/**
 *  更新数据
 *
 */
- (void)updateDataToTableWithUTC:(int)utc thumb_file:(NSString *)thumb_file desc_img:(NSString *)desc_img lastTime:(int)lastTime product_id:(NSString *)product_id;
{
    NSString *sqlstr = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?  , %@ = ?  WHERE %@ = ?",
                        @"yskj_proDuctTable",
                        KEY_DATA_THU,
                        KEY_DATA_DES,
                        KEY_DATA_LASTTIME,
                        KEY_DATA_SHOPID
                        ];
    
    [database executeUpdate:sqlstr,
     thumb_file,
     desc_img,
     [NSNumber numberWithInt:lastTime],
     product_id
     ];
    
    NSLog(@"FMDB_数据修改成功!");

}

//FMDB_删除数据

- (void)deleteDataToTableName:(NSString *)tableName {
    
    YSKJ_DBHelper *dbHelper = [YSKJ_DBHelper sharedHelper];
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@",
                            tableName];
        [database executeUpdate:sqlstr];
    }];
}

//删除某一条数据

- (void)deleteDataProduct_id:(NSString *)product_id from:(int)utc{
    
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
                        @"yskj_proDuctTable",
                        KEY_DATA_SHOPID];
    
    [database executeUpdate:sqlstr,
     product_id
     ];
    
    NSLog(@"FMDB_删除数据成功!");
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Get Data For Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 获取所有有数据的表 */
- (NSMutableArray *)getAllTableNameWithDataForDatabase {
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name LIKE '%@%%' ORDER BY name DESC", @"yskj"];
    
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        
        NSString *tableName = [rs stringForColumn:@"name"];
        
        if ([self getRecordNumber:tableName] > 0) {
            [dataArray addObject:tableName];
        }
    }
    [rs close];
    
    // 如果没有当天的表, 则添加未知项进去
    
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
 //   NSString *currentDate = [self getTableName:[[NSDate date] timeIntervalSince1970]];
    NSString *currentDate=@"2017";
    NSString *listDate    = @"last";
    
    if (dataArray.count > 0) {
        listDate = [NSString stringWithFormat:@"%@", dataArray[0]];
    }
    
    if ([currentDate isEqualToString:listDate] == false) {
        [newArray addObject:currentDate];
        [newArray addObjectsFromArray:dataArray];
        
       
        return newArray;
        
    }
    
    NSLog(@"dataArray=%@",dataArray);
    
    //[newArray removeAllObjects];
    
    return dataArray;
    
    
}

- (void)deleteAllTableDataForDatabase {
    //______________________________________________________________________________________________________
    // 找到所有表
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name LIKE '%@%%' ORDER BY name DESC", @"yskj"];
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        NSString *tableName = [rs stringForColumn:@"name"];
        [deleteArray addObject:tableName];
    }
    [rs close];
    //______________________________________________________________________________________________________
    // 删除所有表
    
    for (int i = 0; i < deleteArray.count; i++) {
        NSString *tableName = [NSString stringWithFormat:@"%@", deleteArray[i]];
        [self deleteTable:tableName];
    }
    
}

// 删除表
- (BOOL)deleteTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![database executeUpdate:sqlstr]) {
        NSLog(@"Delete table error!");
        return NO;
    }
    
    NSLog(@"FMDB_删除表成功! table = %@", tableName);
    return YES;
}

// 清除表
- (BOOL)cleanTable:(NSString *)tableName {
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![database executeUpdate:sqlstr]) {
        NSLog(@"Clean table error!");
        return NO;
    }
    
    NSLog(@"FMDB_清除表中数据成功! table = %@", tableName);
    return YES;
}

/** 取得某个表中最大 utc 时间 */
- (int)getMaxUtcInTable:(NSString *)tableName {
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", tableName, KEY_DATA_UTC];
    FMResultSet *rs = [database executeQuery:sqlstr];
    
    [rs next];
    
    int utc = [rs intForColumn:KEY_DATA_UTC];
    
    [rs close];
    
    return utc;
}

/** 获取所有数据中最大的 utc 时间 */
- (int)getRecentRecordUtc {
    
    if ( [self getTableNumber] <= 0 ) {  // 如果表中没有数据, 则返回 0
        return 0;
    }
    
    // 查找所有表中最大的日期
    
    int maxUtc = 0;
    
    FMResultSet *rs = [database executeQuery:@"SELECT * FROM sqlite_master WHERE type = 'table' RDER BY name DESC"];
    
    [rs next];
    
    {
        NSString *maxTableName = [rs stringForColumn:@"name"];
        
        if ( [self getRecordNumber:maxTableName] ) {
            maxUtc = [self getMaxUtcInTable:maxTableName];
        }
        
        [rs close];
    }
    
    return maxUtc;
}

///** 获取某天的所有数据 */
//- (NSMutableArray *)getSpO2DataForOneDay:(int)utc {
//    
//    NSString *tableName = [self getTableName:utc];
//    return [self getSpO2DataForOneDayWithTableName:tableName ];
//    
//}

// 获取某个表的所有数据
- (NSMutableArray *)getAllDataWithTableName:(NSString *)tableName from:(NSString *)fromType;{
    
    if ([self isTableExsit:tableName] == false || [self getRecordNumber:tableName] <= 0)
        return nil;
 
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    __block FMResultSet *rs;
    YSKJ_DBHelper *dbHelper = [YSKJ_DBHelper sharedHelper];
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", tableName, KEY_DATA_UTC];
        
        rs = [database executeQuery:sqlstr];
    }];
    
    
    while ([rs next]) {
        
        NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
        
        if ([fromType isEqualToString:@"pro"]) {
            [dataDic setObject:[NSString stringWithFormat:@"%@",[rs stringForColumn:KEY_DATA_THU]]   forKey:KEY_DATA_THU];
            [dataDic setObject:[NSString stringWithFormat:@"%@",[rs stringForColumn:KEY_DATA_DES]]   forKey:KEY_DATA_DES];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [rs stringForColumn:KEY_DATA_SHOPID]] forKey:KEY_DATA_SHOPID];
            [dataDic setObject:[NSNumber numberWithInt:[rs intForColumn:KEY_DATA_LASTTIME]]  forKey:KEY_DATA_LASTTIME];

        }else{
            [dataDic setObject:[NSString stringWithFormat:@"%@",[rs stringForColumn:KEY_DATA_THU]]   forKey:KEY_DATA_THU];
            [dataDic setObject:[NSString stringWithFormat:@"%@", [rs stringForColumn:KEY_DATA_SHOPID]] forKey:KEY_DATA_SHOPID];
            
        }
        
        [dataArray addObject:dataDic];
        
    }
    
    [rs close];
    
  //  NSLog(@"dataArray=%@",dataArray);
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(readDataBaseData:withDatabaseMan:)]) {
        if ([fromType isEqualToString:@"pro"]) {
            [self.delegate readDataBaseData:dataArray withDatabaseMan:self];
        }else{
            [self.delegate readDataBaseDataWithSpaceData:dataArray withDatabaseMan:self];
        }
        
    }
    return dataArray;
}
// 获取某个表的某一key数据
- (void)getOneProDuctDataTableName:(NSString *)tableName with:(NSString *)product_id getStr:(NSString*)getStr{
    
    if ([self isTableExsit:tableName] == false || [self getRecordNumber:tableName] <= 0) return;
    //______________________________________________________________________________________________________
    // 查找数据并封装
    
    
    NSString *dataStr = [[NSString alloc] init];
    
    __block FMResultSet *rs;
    YSKJ_DBHelper *dbHelper = [YSKJ_DBHelper sharedHelper];
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' ORDER BY %@ DESC", tableName,KEY_DATA_SHOPID,product_id, KEY_DATA_UTC];

        rs = [database executeQuery:sqlstr];
        
    }];
    
   
    while ([rs next]) {
        
        dataStr=[NSString stringWithFormat:@"%@",[rs stringForColumn:getStr]] ;
        
    }
    [rs close];
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(readOneDataBaseData:withDatabaseMan:)]) {
        [self.delegate readOneDataBaseData:dataStr withDatabaseMan:self];
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Other Method
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/// 获取反向数组
+ (NSArray *)getInversionArray:(NSArray *)array {
    
    if (array.count > 0 == false) {
        return nil;
    }
    
    NSMutableArray *inversionArray = [[NSMutableArray alloc] init];
    for (int i = (int)array.count - 1; i >= 0; i--) {
        [inversionArray addObject:array[i]];
    }
    return inversionArray;
    
}

@end
