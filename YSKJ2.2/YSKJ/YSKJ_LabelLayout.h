//
//  YSKJ_CollModelViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/17.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol YSKJ_LabelLayoutDelegate <NSObject>
/**
 *  数据源代理
 *
 *  @return 标签的标题数组
 */
-(NSArray*)OJLLabelLayoutTitlesForLabel;

@end

@interface YSKJ_LabelLayout : UICollectionViewLayout
@property (nonatomic, weak) id <YSKJ_LabelLayoutDelegate> delegate;
/**
 *  同一行之间标签的间距
 */
@property (nonatomic, assign) CGFloat panding;
/**
 *  同一列之间标签的间距
 */
@property (nonatomic, assign) CGFloat rowPanding;

@end
