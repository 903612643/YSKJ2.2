//
//  YSKJ_OrderDetailTableViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/7/27.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDetailTableViewCell.h"

#import "YSKJ_OrderListCollectionViewCell.h"

#import "YSKJ_OrderProjectDetailViewController.h"

#import <SDAutoLayout/SDAutoLayout.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderDetailTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10)];
        view.backgroundColor = UIColorFromHex(0xefefef);
        [self addSubview:view];
        
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 100, 14)];
        self.date.textColor = UIColorFromHex(0x999999);
        self.date.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.date];
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, 200, 14)];
        self.name.font = [UIFont systemFontOfSize:14];
        self.name.textColor = UIColorFromHex(0x333333);
        [self addSubview:self.name];
        
        self.number = [[UILabel alloc] initWithFrame:CGRectMake(20, 178-30, 80, 14)];
        self.number.font = [UIFont systemFontOfSize:14];
        self.number.textColor = UIColorFromHex(0x333333);
        [self addSubview:self.number];
        
        self.totailePrice = [[UILabel alloc] initWithFrame:CGRectMake(114,  178-30, 200, 14)];
        self.totailePrice.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.totailePrice];
        
        self.waitPass = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -80, 25, 60, 14)];
        self.waitPass.textAlignment = NSTextAlignmentRight;
        self.waitPass.font = [UIFont systemFontOfSize:14];
        self.waitPass.textColor = UIColorFromHex(0xf39800);
        [self addSubview:self.waitPass];
        
        self.arrowsImage =[[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 35, 78, 15, 28)];
        self.arrowsImage.image=[UIImage imageNamed:@"jiantou"];
        [self addSubview:self.arrowsImage];

        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(80, 80);
        
        _collect = [[UICollectionView alloc]initWithFrame:CGRectMake(20, 54, [UIScreen mainScreen].bounds.size.width - 140, 80) collectionViewLayout:layout];
        _collect.backgroundColor=[UIColor whiteColor];
        _collect.delegate=self;
        _collect.dataSource=self;
        [_collect registerClass:[YSKJ_OrderListCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
        [self addSubview:_collect];
    
        self.button = [[UIButton alloc] init];
        self.button.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
        self.button.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView (self,0)
        .topSpaceToView(self,10)
        .bottomSpaceToView(self,10);
        
        self.orderCancleLogo = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 160, 10, 60, 50)];
        self.orderCancleLogo.hidden = YES;
        self.orderCancleLogo.image = [UIImage imageNamed:@"yiliushi"];
        [self addSubview:self.orderCancleLogo];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 178, [UIScreen mainScreen].bounds.size.width, 1)];
        self.line.backgroundColor = UIColorFromHex(0xd8d8d8);
        [self addSubview:self.line];
        
        self.leftBut = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-320, 188, 128, 44)];
        UIColor *titCol = UIColorFromHex(0xf39800);
        self.leftBut.hidden = YES;
        self.leftBut.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.leftBut setTitleColor:titCol forState:UIControlStateNormal];
        [self addSubview:self.leftBut];
        self.leftBut.layer.cornerRadius = 4;
        self.leftBut.layer.masksToBounds = YES;
        self.leftBut.layer.borderWidth = 1;
        self.leftBut.layer.borderColor = titCol.CGColor;
        
        self.rightBut = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-152, 188, 132, 44)];
        UIColor *titCol1 = UIColorFromHex(0xf39800);
        self.rightBut.hidden = YES;
        self.rightBut.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.rightBut setTitleColor:titCol1 forState:UIControlStateNormal];
        [self addSubview:self.rightBut];
        self.rightBut.layer.cornerRadius = 4;
        self.rightBut.layer.masksToBounds = YES;
        self.rightBut.layer.borderWidth = 1;
        self.rightBut.layer.borderColor = titCol.CGColor;
        
    }
    
    return self;
}

-(void)setNameStr:(NSString *)nameStr
{
    _nameStr = nameStr;
    self.name.text = nameStr;
}

-(void)setDateStr:(NSString *)dateStr
{
    _dateStr = dateStr;
    self.date.text = dateStr;
    
}

-(void)setNumberStr:(NSString *)numberStr
{
    _numberStr = numberStr;
    self.number.text = [NSString stringWithFormat:@"共%@件商品",numberStr];
    
}

-(void)setTotailePriceStr:(NSString *)totailePriceStr
{
    _totailePriceStr = totailePriceStr;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:totailePriceStr];
    UIColor *titC = UIColorFromHex(0xf95f3e);
    [attributedString addAttribute:NSForegroundColorAttributeName value:titC range:NSMakeRange(4,totailePriceStr.length-4)];
    
    self.totailePrice.attributedText=attributedString;

}

-(void)setWaitPassStr:(NSString *)waitPassStr
{
    _waitPassStr = waitPassStr;
    self.waitPass.text = waitPassStr;
}

-(void)setObj:(NSDictionary *)obj
{
    _obj = obj;
    
    NSDictionary *dataInfo = [obj objectForKey:@"data_info"];
    
    NSArray *pdata = [dataInfo objectForKey:@"pdata"];
    
    NSMutableArray *tempData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<pdata.count; i++) {
        
        NSDictionary *dict = pdata[i];
        
        NSArray *data = [dict objectForKey:@"data"];
        
        for (NSDictionary *dict in data) {
            
            [tempData addObject:dict];
        }
        
    }
    _list = tempData;

    
    [_collect reloadData];

}
-(void)setWidth:(float)width
{
    _width = width;
    
    _collect.frame = CGRectMake(20, 54, width - 140, 80);
    
     self.arrowsImage.frame =CGRectMake(width - 35, 80, 15, 28);
    
    self.waitPass.frame = CGRectMake(width - 80, 25, 60, 14);
    
    self.orderCancleLogo.frame = CGRectMake(width - 156, 10, 60, 50);
    
    self.leftBut.frame = CGRectMake(width-320, 188, 128, 44);
    self.rightBut.frame = CGRectMake(width-152, 188, 132, 44);
    
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _list.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YSKJ_OrderListCollectionViewCell *proImageCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    NSDictionary *obj = _list[indexPath.row];
    
    proImageCell.url = [obj objectForKey:@"thumb_file"];
    
    return proImageCell;
    
}


//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {0,20,0,20};
    return top;
}

@end
