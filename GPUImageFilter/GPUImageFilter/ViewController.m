//
//  ViewController.m
//  GPUImageTest
//
//  Created by 周松 on 17/4/20.
//  Copyright © 2017年 周松. All rights reserved.
//
#import "ViewController.h"
#import "AlbumCollectionViewCell.h"
#import "TZImagePickerController.h"
#import "Masonry.h"
#import "GPUImage.h"
#import "GPUImageSketchFilter.h"
#import "GPUImageMosaicFilter.h"
#import "GPUImageToonFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageStretchDistortionFilter.h"
#import "GPUImageGlassSphereFilter.h"
#import "GPUImageHazeFilter.h"
#import "GPUImageDissolveBlendFilter.h"
#import "GPUImageEmbossFilter.h"
#import "GPUImageSphereRefractionFilter.h"
#import "GPUImageSwirlFilter.h"
#import "GPUImageEmbossFilter.h"
#import "GPUImageScreenBlendFilter.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImagePerlinNoiseFilter.h"
#import "GPUImageExclusionBlendFilter.h"
#import "GPUImageLightenBlendFilter.h"
#import <Photos/Photos.h>


#define  KSCREENW [UIScreen mainScreen].bounds.size.width
#define KSCREENH [UIScreen mainScreen].bounds.size.height
static NSString *reuseId = @"AlbumCollectionViewCellID";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) NSArray *cellFilterFlags;//每个cell的滤镜标识
@property (nonatomic,strong) GPUImagePicture *startImage;//初始化图片
@property (nonatomic,strong) GPUImageOutput <GPUImageInput>   *filter;
@property (nonatomic,strong) UIImage *outputImage;///处理后的图片
@property (nonatomic,strong) NSArray *cellTitles;//cell的文字
@property (nonatomic,strong) UIImage *originalImage;//未被处理的图片

@end

@implementation ViewController
#pragma mark -- 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.itemSize = CGSizeMake(75, 100);
        CGFloat collectionViewHeight = KSCREENH - CGRectGetMaxY(self.imageView.frame);
        CGRect frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), KSCREENW, collectionViewHeight);
        _collectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (KSCREENH - KSCREENW) * 0.3, KSCREENW, KSCREENW)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        [_imageView addGestureRecognizer:longPress];
        [self.view addSubview:_imageView];
    }
    return  _imageView;
}

- (UIButton *)button {
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"开启滤镜(长按图片可保存)" forState:UIControlStateNormal];
        [self.view addSubview:_button];
        _button.backgroundColor = [UIColor orangeColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:16];
        [_button addTarget:self action:@selector(addImageButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _button;
}
///添加图片的点击事件
- (void)addImageButtonClick {
    TZImagePickerController *imageController = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imageController.needCircleCrop = NO;
    [imageController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photo, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photo.count) {
            self.imageView.image = photo[0];
            self.originalImage = photo[0];
            //刷新数据,预览经过处理的图片
            [self.collectionView reloadData];
        }
    }];
    [self presentViewController:imageController animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellFilterFlags = @[@"GPUImageSketchFilter",/*素描 */
                             @"GPUImageCrosshatchFilter",/*交叉线阴影*/
                             @"GPUImageToonFilter",/*卡通效果*/
                             @"GPUImageGaussianBlurFilter",/*高斯模糊*/
                             @"GPUImageStretchDistortionFilter",/*伸展失真(哈哈镜)*/
                             @"GPUImageGlassSphereFilter",/*水晶球效果*/
                             @"GPUImageHazeFilter",/*朦胧加暗*/
                             @"GPUImagePerlinNoiseFilter",/*噪点*/
                             @"GPUImageEmbossFilter",/*浮雕*/
                             @"GPUImageSphereRefractionFilter",/*球形折射,倒立*/
                             @"GPUImageSwirlFilter",/*漩涡，中间形成卷曲的画面*/
                             @"GPUImageEmbossFilter",/*浮雕效果，带有点3d的感觉*/
                             @"GPUImageVignetteFilter",/*晕影*/
                             ];
    self.cellTitles = @[@"素描",@"交叉线阴影",@"卡通效果",@"高斯模糊",@"伸展失真",@"水晶球",@"朦胧",@"噪点",@"浮雕",@"球形折射",@"旋涡",@"3d浮雕",@"晕影"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(40);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
}

#pragma mark --UIColletionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellFilterFlags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    UIImage *image = [self createWithFilterClassNameL:self.cellFilterFlags[indexPath.item] inputImage:self.originalImage];
    cell.filterImageView.image = image;
    cell.filterLabel.text = self.cellTitles[indexPath.item];
    return cell;
}

//点击cell,让中间的大图显示处理后的结果
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = [self createWithFilterClassNameL:self.cellFilterFlags[indexPath.item] inputImage:self.originalImage];
    self.imageView.image = nil;
    self.imageView.image = image;
    
}

///根据给的滤镜数组返回处理后的图片
- (UIImage *)createWithFilterClassNameL:(NSString *)filterName inputImage:(UIImage *)inputImage{
    //初始化图片
    self.startImage = [[GPUImagePicture alloc]initWithImage:inputImage];
    //初始化滤镜
    if ([filterName isEqualToString:@"GPUImageSketchFilter"]) {
        self.filter = [[GPUImageSketchFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageCrosshatchFilter"] ) {
        self.filter = [[GPUImageCrosshatchFilter alloc]init];
    } else  if ([filterName isEqualToString:@"GPUImageToonFilter"]) {
        self.filter = [[GPUImageToonFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageGaussianBlurFilter"]) {
        self.filter = [[GPUImageGaussianBlurFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageStretchDistortionFilter"]) {
        self.filter = [[GPUImageStretchDistortionFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageGlassSphereFilter"]) {
        self.filter = [[GPUImageGlassSphereFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageHazeFilter"]) {
        self.filter = [[GPUImageHazeFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImagePerlinNoiseFilter"]) {
        self.filter = [[GPUImagePerlinNoiseFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageEmbossFilter"]) {
        self.filter = [[GPUImageEmbossFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageSphereRefractionFilter"]) {
        self.filter = [[GPUImageSphereRefractionFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageSwirlFilter"]) {
        self.filter = [[GPUImageSwirlFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageEmbossFilter"]) {
        self.filter = [[GPUImageEmbossFilter alloc]init];
    } else if ([filterName isEqualToString:@"GPUImageVignetteFilter"]) {
        self.filter = [[GPUImageVignetteFilter alloc]init];
    }
    //向图片添加滤镜
    [self.startImage addTarget:self.filter];
    //开始处理图片
    [self.filter useNextFrameForImageCapture];
    [self.startImage processImage];
    //输出处理后的图片
    self.outputImage = [self.filter imageFromCurrentFramebuffer];
    return self.outputImage;
}
///长按图片保存到相册
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否保存到相册" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            //写入相册
            [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            //完成之后
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alert completion:nil];
    }];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
