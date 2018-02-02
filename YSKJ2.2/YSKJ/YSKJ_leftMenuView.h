//
//  YSKJ_leftMenuView.h
//  YSKJ
//
//  Created by YSKJ on 17/8/1.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_leftMenuView : UIView

@property (nonatomic,strong) UIButton *loginButton;

@property (nonatomic,strong) UIButton *head;

@property (nonatomic,strong) UILabel *name;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIView *line;

@property (nonatomic,strong) UIButton *exit;


@property (nonatomic,strong)UIImage *image;

@property (nonatomic,retain)NSString *nameStr;


@end
