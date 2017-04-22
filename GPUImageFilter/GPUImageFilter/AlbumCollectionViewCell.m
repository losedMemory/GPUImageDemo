//
//  AlbumCollectionViewCell.m
//  GPUImageTest
//
//  Created by 周松 on 17/4/21.
//  Copyright © 2017年 周松. All rights reserved.
//

#import "AlbumCollectionViewCell.h"
#import "Masonry.h"

@interface AlbumCollectionViewCell ()

@end
@implementation AlbumCollectionViewCell

#pragma  mark --懒加载
- (UILabel *)filterLabel {
    if (_filterLabel == nil) {
        _filterLabel = [[UILabel alloc]init];
        _filterLabel.textColor = [UIColor grayColor];
        _filterLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _filterLabel.font = [UIFont systemFontOfSize:14];
        _filterLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_filterLabel];
    }
    return _filterLabel;
}

- (UIImageView *)filterImageView {
    if (_filterImageView == nil) {
        _filterImageView = [[UIImageView alloc]init];
        _filterImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_filterImageView];
    }
    return _filterImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.filterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.size.mas_offset(CGSizeMake(75, 75));
    }];
    [self.filterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(25);
    }];
}

@end
