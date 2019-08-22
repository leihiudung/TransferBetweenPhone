//
//  AlbumCollectionViewCell.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "AlbumCollectionViewCell.h"
@interface AlbumCollectionViewCell()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation AlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageView setClipsToBounds:YES];
    [self.contentView addSubview:self.imageView];
    
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    self.imageView.image = thumbnailImage;
    
}
@end
