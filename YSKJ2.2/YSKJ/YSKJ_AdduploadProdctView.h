//
//  YSKJ_AdduploadProdctView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/1.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_AdduploadProdctView : UIView

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,strong) UIView *loadingView;

@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic,strong) UILabel *progressLable;

@property (nonatomic,strong) UIButton *loadData;

@property (nonatomic, retain) NSString *titleStr;

@property (nonatomic, assign) float progressValues;

@property (nonatomic, retain) NSString *progressTitle;


@end
