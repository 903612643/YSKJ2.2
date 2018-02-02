//
//  DataDictionaryKey.h
//  YSKJ
//
//  Created by YSKJ on 16/11/4.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#ifndef KONSUNG_DataDictionaryKey_h
#define KONSUNG_DataDictionaryKey_h


#define KEY_TABLE_CREATE_UTC       @"UTC    interger"          
#define KEY_TABLE_CREATE_DATE      @"Date    varchar"          //输入数据的时间
#define KEY_TABLE_CREATE_THU      @"thumb_file   varchar"      //主图
#define KEY_TABLE_CREATE_DES      @"desc_img    varchar"        //关联图片
#define KEY_TABLE_CREATE_MOD      @"desc_model    varchar"        //3D图片
#define KEY_TABLE_CREATE_SHOPID      @"product_id    varchar UNIQUE"    //商品id
#define KEY_TABLE_CREATE_LASTTIME      @"lastTime    interger"    //最后更新时间


#define KEY_DATA_UTC       @"UTC"
#define KEY_DATA_DATE      @"Date"
#define KEY_DATA_THU   @"thumb_file"
#define KEY_DATA_DES     @"desc_img"
#define KEY_DATA_MOD     @"desc_model"
#define KEY_DATA_SHOPID     @"product_id"
#define KEY_DATA_LASTTIME     @"lastTime"



#endif
