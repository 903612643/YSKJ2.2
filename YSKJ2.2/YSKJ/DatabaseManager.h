//  DatabaseManager.h
//  YSKJ
//
//  Created by YSKJ on 16/11/29.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DataDictionaryKey.h"

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

#import "YSKJ_UTCDataCalss.h"

@class DatabaseManager;

static NSString * const Folder_DB   = @"YSKJ_DB";    //数据库目录
static NSString * const DB_NAME_PRO = @"YSKJ_Pro_DataBase";  //数据库名

@protocol DatabaseManagerDelegate <NSObject>

@optional

-(void)readDataBaseDataWithSpaceData:(NSMutableArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;

-(void)readDataBaseData:(NSMutableArray *)array withDatabaseMan:(DatabaseManager *)readDataCalss;

-(void)readOneDataBaseData:(NSString *)dataString withDatabaseMan:(DatabaseManager *)readDataCalss;

-(void)numData:(int)num withDatabaseMan:(DatabaseManager *)readDataCalss;

@end

@interface DatabaseManager : NSObject

@property (nonatomic,assign)id<DatabaseManagerDelegate>delegate;

@property (nonatomic,retain) NSString *type;

/// 获取反向数组
+ (NSArray *)getInversionArray:(NSArray *)array;

- (void)openDatabase;

/// 关闭数据库
- (void)closeDatabase;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *  添加数据至数据库
 *
 */

- (void)addDataToTableCurrentTableName:(NSString *)tableName  thumb_file:(NSString *)thumb_file desc_img:(NSString *)desc_img desc_model:(NSString *)desc_model product_id:(NSString *)product_id lastTime:(int)lastTime;

/**
 *  更新数据
 *
 */
- (void)updateDataToTableWithUTC:(int)utc thumb_file:(NSString *)thumb_file desc_img:(NSString *)desc_img lastTime:(int)lastTime product_id:(NSString *)product_id;
/**
 *  删除全部数据
 *
 *  @param utc 数据的时间戳
 */
- (void)deleteDataToTableName:(NSString *)tableName;

/**
 *  删除某一条数据
 *
 *  @param utc 数据的时间戳
 */
- (void)deleteDataProduct_id:(NSString *)product_id from:(int)utc;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Get Data For Database
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/** 获取所有有数据的表 */
- (NSMutableArray *)getAllTableNameWithDataForDatabase;
/** 删除所有表 */
- (void)deleteAllTableDataForDatabase;

/** 获取某天的所有数据 */
//- (NSMutableArray *)getSpO2DataForOneDay:(int)utc;

/** 获取某个表的所有数据 */
- (NSMutableArray *)getAllDataWithTableName:(NSString *)tableName from:(NSString *)fromType;

// 获取某个表的某一条数据
- (void)getOneProDuctDataTableName:(NSString *)tableName with:(NSString *)product_id getStr:(NSString*)getStr;

/** 获取表中记录数 */
- (int)getRecordNumber:(NSString *)tableName;


@end
