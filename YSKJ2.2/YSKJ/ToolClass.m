//
//  ToolClass.m
//  YSKJ
//
//  Created by YSKJ on 16/12/14.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import "ToolClass.h"

@implementation ToolClass

+(BOOL)phone:(NSString *)phoneStr;
{
    /**
     * 移动号段正则表达式
     */
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    /**
     * 联通号段正则表达式
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    /**
     * 电信号段正则表达式
     */
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
    BOOL isMatch1 = [pred1 evaluateWithObject:phoneStr];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
    BOOL isMatch2 = [pred2 evaluateWithObject:phoneStr];
    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
    BOOL isMatch3 = [pred3 evaluateWithObject:phoneStr];
    
    if (isMatch1 || isMatch2 || isMatch3) {
        // NSLog(@"号码正确");
        return YES;
        
    }
    //  NSLog(@"格式不正确");
    return NO;
}
//判断是否含有非法字符 yes 有  no没有
+(BOOL)JudgeTheillegalCharacter:(NSString *)content
{
    //提示 姓名不能输入特殊字符
    NSString *str =@"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![emailTest evaluateWithObject:content]) {
        return YES;
    }
    return NO;
}

//json解析字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
//json解析数组
+ (NSArray *)arrayWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                   options:NSJSONReadingMutableContainers
                                                     error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}
//字典解析json
+ (NSString *)stringWithDict:(NSDictionary *)dict;
{
    //解析成json字符串
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

//去除未转义的控制字符
+(NSString *)removeUnescapedCharacter:(NSString *)inputStr
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];
    
    if (range.location != NSNotFound)
    {
        
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        
        while (range.location != NSNotFound)
        {
            
            [mutable deleteCharactersInRange:range];
            
            range = [mutable rangeOfCharacterFromSet:controlChars];
            
        }
        
        return mutable;
        
    }
    
    return inputStr;
}

/**
 *  将 UTC 时间转换为字符串
 *
 *  @param UTC    将 UTC 时间转换为字符串
 *  @param format @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return 字符串
 */
+ (NSString *)utcToDateString:(int)UTC dateFormat:(NSString *)format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:UTC]];
    return dateString;
}

/**
 *  将字符串转换为 UTC 时间
 *
 *  @param date_string 时间字符串
 *  @param format      @"yyyy_MM_dd HH:mm:ss Z"
 *
 *  @return utc 时间
 */
+ (int)dateFormatToUTC:(NSString *)date_string dateFormat:(NSString*)format {
    
    int utc = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    
    utc = [[dateFormatter dateFromString:date_string] timeIntervalSince1970];
    return utc;
}

@end
