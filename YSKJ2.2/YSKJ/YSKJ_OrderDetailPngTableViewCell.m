//
//  YSKJ_OrderDetailPngTableViewCell.m
//  YSKJ
//
//  Created by YSKJ on 17/8/3.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_OrderDetailPngTableViewCell.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import <SDWebImage/UIButton+WebCache.h>

#import <SDWebImage/UIImageView+WebCache.h>

#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_OrderDetailPngTableViewCell

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
        
        self.productImage = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 130, 130)];
        [self addSubview:self.productImage];
        
        self.proName = [[UILabel alloc] init];
        self.proName.textColor = UIColorFromHex(0x333333);
        self.proName.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.proName];
        self.proName.sd_layout
        .leftSpaceToView(self, 160)
        .widthIs(250)
        .heightIs(14)
        .topSpaceToView(self, 10);
        
        self.standardLable = [[UILabel alloc] init];
        self.standardLable .textColor = UIColorFromHex(0x999999);
        self.standardLable .font = [UIFont systemFontOfSize:12];
        [self addSubview:self.standardLable ];
        self.standardLable.sd_layout
        .leftSpaceToView(self, 160)
        .widthIs(250)
        .heightIs(14)
        .topSpaceToView(self.proName, 25);
        
        self.beizhuLable = [[UILabel alloc] init];
        self.beizhuLable.textColor = UIColorFromHex(0x999999);
        self.beizhuLable.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.beizhuLable];
        self.beizhuLable.sd_layout
        .leftSpaceToView(self, 160)
        .widthIs(250)
        .heightIs(14)
        .topSpaceToView(self.proName, 64);
        
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(110, 14);
        
        _collect = [[UICollectionView alloc]initWithFrame:CGRectMake(340, 35, [UIScreen mainScreen].bounds.size.width - 380, 80) collectionViewLayout:layout];
        _collect.backgroundColor = [UIColor whiteColor];
        _collect.delegate=self;
        _collect.dataSource=self;
        [_collect registerClass:[YSKJ_OrderDetailPngCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
        [self addSubview:_collect];

    }
    
    return self;
    
}
-(void)setUrl:(NSString *)url
{
    _url = url;
    
    [self.productImage sd_setImageWithURL:[[NSURL alloc] initWithString:url] forState:UIControlStateNormal];

    [self.productImage.imageView sd_setImageWithPreviousCachedImageWithURL:[[NSURL alloc] initWithString:url] placeholderImage:[UIImage imageNamed:@"loading1"] options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

        float scaleW;
        if (image.size.width>=image.size.height) {
            scaleW=130/image.size.width;
        }else{
            scaleW=130/image.size.height;
        }

        if (image.size.width>0 && image.size.height>0) {

            self.productImage.imageEdgeInsets=UIEdgeInsetsMake((self.productImage.frame.size.height-scaleW*(image.size.height))/2, (self.productImage.frame.size.width-scaleW*(image.size.width))/2, (self.productImage.frame.size.height-scaleW*(image.size.height))/2, (self.productImage.frame.size.width-scaleW*(image.size.width))/2);
        }
    }];
    
}

-(void)setProNameStr:(NSString *)proNameStr
{
    _proNameStr = proNameStr;
    self.proName.text = proNameStr;
}

-(void)setStandardLableStr:(NSString *)standardLableStr
{
    _standardLableStr = standardLableStr;
    self.standardLable.text = standardLableStr;
}

-(void)setBeizhuLableStr:(NSString *)beizhuLableStr
{
    _beizhuLableStr = beizhuLableStr;
    self.beizhuLable.text = beizhuLableStr;
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.priceArr.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YSKJ_OrderDetailPngCollectionViewCell *priceCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    priceCell.priceStr = self.priceArr[indexPath.row];
    
    return priceCell;
    
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {33,0,33,0};
    return top;
}

-(void)setPriceArr:(NSArray *)priceArr
{
    _priceArr = priceArr;
    [_collect reloadData];
    
}


@end
