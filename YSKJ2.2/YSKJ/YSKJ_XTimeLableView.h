//
//  YSKJ_XlineView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/25.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_XTimeLableView : UIView

@property (nonatomic,strong) UILabel *timeLable1;
@property (nonatomic,strong) UILabel *timeLable2;
@property (nonatomic,strong) UILabel *timeLable3;
@property (nonatomic,strong) UILabel *timeLable4;

@property (nonatomic,assign) float timeLable1X;
@property (nonatomic,assign) float timeLable2X;
@property (nonatomic,assign) float timeLable3X;
@property (nonatomic,assign) float timeLable4X;

@property (nonatomic,copy) NSString* timeLable1Xtext;
@property (nonatomic,copy) NSString* timeLable2Xtext;
@property (nonatomic,copy) NSString* timeLable3Xtext;
@property (nonatomic,copy) NSString* timeLable4Xtext;


@end
