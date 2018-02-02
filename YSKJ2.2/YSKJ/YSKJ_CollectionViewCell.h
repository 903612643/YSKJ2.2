//
//  YSKJ_CollModelViewController.m
//  YSKJ
//
//  Created by YSKJ on 16/11/17.
//  Copyright © 2016年 5164casa.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;

-(void)setTitle:(NSString*)title;

@end
