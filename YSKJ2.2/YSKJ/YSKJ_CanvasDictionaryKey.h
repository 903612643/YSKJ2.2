//
//  YSKJ_CanvasDictionaryKey.h
//  YSKJ
//
//  Created by 羊德元 on 2016/12/8.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#ifndef YSKJ_CanvasDictionaryKey_h
#define YSKJ_CanvasDictionaryKey_h

#import <SDAutoLayout/UIView+SDAutoLayout.h>
#import "HttpRequestCalss.h"
#import "DatabaseManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <MJRefresh/MJRefresh.h>
#import "YSKJ_CollectionViewCell.h"
#import "YSKJ_LabelLayout.h"
#import "YSKJ_PlanViewController.h"

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

#define THEWIDTH  [UIScreen mainScreen].bounds.size.width
#define THEHEIGHT  [UIScreen mainScreen].bounds.size.height

#define ALLPRODLIST @"http://www.5164casa.com/api/saas/store/getfavproduct"  //方案列表

#define PICURL @"http://odso4rdyy.qnssl.com"                    //图片固定地址

#define  GETLABLE @"http://www.5164casa.com/api/saas/store/getfavlabel"    //获取标签

//导航栏上button Tag值
#define TAG 1000
#define TAG1 1001
#define TAG2 1002
#define TAG3 1003
#define TAG4 1004
#define TAG5 1005
#define TAG6 1006
#define TAG9 1009


//配置PopView的属性

#define POPH 42      //popView的高度
#define PPDING 0  //lable 之间的间隔
#define LEFTPPD 0  //lable在父PopView左右间隔
#define FONT  14   //lable字体大小

//1.商品列表collectionView配置

#define PROCOLLETIONVIEW_T  63     //顶部离导航栏
#define PROCOLLETIONITEM_W  140     //cell 的宽
#define PROCOLLETIONITEM_H  110     //cell 的高

//2.标签列表collectionView配置

#define LabCOLLETIONVIEW_T  63     //顶部离导航栏
#define LabCOLLETIONVIEW_PDD  24     //行间距
#define LabCOLLETIONVIEW_ROWPDD  28     //列间距

//3.背景空间collectionView配置
#define SPACOLLETIONVIEW_T  63     //顶部离导航栏
#define SPACOLLETIONVIEW_ITEMPDD  16     //cell之间的间距，宽度自适应
#define SPACOLLETIONITEM_H  180     //cell高度

//3.添加商品collectionView配置
#define ADDPROCOLLETIONVIEW_T  128     //顶部离导航栏
#define ADDPROCOLLETIONVIEW_ITEMPDD  12     //cell之间的间距，宽度自适应
#define ADDPROCOLLETIONITEM_H  192     //cell高度

#endif /* YSKJ_CanvasDictionaryKey_h */
