//
//  YSKJ_ProductViewDetail.m
//  YSKJ
//
//  Created by YSKJ on 17/9/14.
//  Copyright © 2017年 5164casa.com. All rights reserved.
//

#import "YSKJ_ProductViewDetail.h"

#import <SDAutoLayout/SDAutoLayout.h>

#import "YSKJ_PicCollectionViewCell.h"

#import "ToolClass.h"


#define UIColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1]

@implementation YSKJ_ProductViewDetail

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    
    if (self == [super initWithFrame:frame]) {
        
        self.productTitle=[[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width/2, 14)];
        [self addSubview:self.productTitle];
        self.productTitle.textColor=UIColorFromHex(0x333333);
        self.productTitle.backgroundColor=[UIColor clearColor];
        self.productTitle.font=[UIFont systemFontOfSize:14];
 
        self.productPrice=[UILabel new];
        [self addSubview:self.productPrice];
        self.productPrice.textColor=UIColorFromHex(0xf32a00);
        self.productPrice.backgroundColor=[UIColor clearColor];
        self.productPrice.font=[UIFont systemFontOfSize:20];
        self.productPrice.sd_layout
        .leftSpaceToView(self,8)
        .topSpaceToView(self.productTitle,6)
        .widthIs(40)
        .heightIs(20);
        
        self.productTexture=[UILabel new];
        [self addSubview:self.productTexture];
        self.productTexture.textColor=UIColorFromHex(0x999999);
        self.productTexture.backgroundColor=[UIColor clearColor];
        self.productTexture.font=[UIFont systemFontOfSize:14];
        self.productTexture.sd_layout
        .leftSpaceToView(self.productPrice,14)
        .topSpaceToView(self.productTitle,9)
        .widthIs(400)
        .heightIs(14);
        
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(42, 42);
        
        _collect = [[UICollectionView alloc]initWithFrame:CGRectMake((self.frame.size.width -(44*3+10*2+30*2)) -20 , -5, 44*3+10*2+30*2, 55) collectionViewLayout:layout];
        _collect.backgroundColor=[UIColor clearColor];
        _collect.delegate=self;
        _collect.dataSource=self;
        _collect.scrollEnabled = NO;
        [_collect registerClass:[YSKJ_PicCollectionViewCell class] forCellWithReuseIdentifier:@"cellid"];
        [self addSubview:_collect];
        
        
        UIView *line=[UIView new];
        line.backgroundColor=UIColorFromHex(0xd7d7d7);
        [self addSubview:line];
        line.sd_layout
        .leftEqualToView(self)
        .rightEqualToView(self)
        .topSpaceToView(self,0)
        .heightIs(1);

    }
    
    return self;
    
}

-(void)setObj:(NSDictionary *)obj
{
    _obj = obj;
    
    NSDictionary *dataDict=[obj objectForKey:@"data"];
    self.productTitle.text=[dataDict objectForKey:@"name"];
    
    NSString *priceStr=[NSString stringWithFormat:@"¥%d",[[dataDict objectForKey:@"price"] intValue]];
    
    self.productPrice.text=priceStr;
    
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:20]};
    CGSize labelsize = [priceStr boundingRectWithSize:CGSizeMake(1000, 100) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    self.productPrice.sd_layout
    .widthIs(labelsize.width);
    [self.productPrice updateLayout];
    
    NSDictionary *arrdict=[ToolClass dictionaryWithJsonString:[dataDict objectForKey:@"attributes"]];
    NSArray *allkeys=[arrdict allKeys];
    
    for (NSString *key in allkeys) {
        if (![key isEqualToString:@"规格"]) {
            self.productTexture.text=@"";
        }
    }
    
    for (NSString *key in allkeys) {
        if ([key isEqualToString:@"规格"]) {
            NSDictionary *guigeDict=[arrdict valueForKey:key];
            NSMutableArray *tempArr=[NSMutableArray new];
            [guigeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [tempArr addObject:[NSString stringWithFormat:@"%@%@",key,obj]];
            }];
            if (tempArr.count==2) {
                [tempArr exchangeObjectAtIndex:0 withObjectAtIndex:1];
            }else if (tempArr.count==3){
                [tempArr exchangeObjectAtIndex:0 withObjectAtIndex:2];
                [tempArr exchangeObjectAtIndex:1 withObjectAtIndex:2];
            }
            self.productTexture.text= [NSString stringWithFormat:@"规格：%@mm",[tempArr componentsJoinedByString:@"*"]]; //为分隔符
        }
    }
    
    _list=[ToolClass arrayWithJsonString:[dataDict objectForKey:@"desc_model"]];
    
    [_collect reloadData];
    
}

-(void)setPicStr:(NSString *)picStr
{
    _picStr = picStr;
    
    _selectIndex = 0;
    
    for (int i=0; i<_list.count; i++) {
        if ([picStr isEqualToString:_list[i]]) {
            _selectIndex = i;
        }
    }
    
    [_collect reloadData];
    
}

#pragma mark UICollectionViewDataSource,UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _list.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _proImageCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    _proImageCell.url = _list[indexPath.row];
    
    if (_selectIndex == indexPath.row) {
        
        _proImageCell.layer.borderColor = UIColorFromHex(0xf39800).CGColor;
        _proImageCell.layer.borderWidth = 1;
        
    }else{
    
        _proImageCell.layer.borderColor = UIColorFromHex(0x999999).CGColor;
        _proImageCell.layer.borderWidth = 1;
    
    }

    return _proImageCell;
    
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top = {0,10,11,0};
    return top;
}



@end
