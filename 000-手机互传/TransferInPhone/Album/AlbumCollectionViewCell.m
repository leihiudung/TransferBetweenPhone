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
@property (nonatomic, strong) UIImageView *chosenImageView;
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
    
    self.chosenImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 30, self.bounds.size.height - 30, 30, 30)];
    [self.chosenImageView setImage:[UIImage imageNamed:@"status_unselect"]];
    [self.contentView addSubview:self.chosenImageView];
    
    
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    self.imageView.image = thumbnailImage;
    
}

- (UIImage *)thumbnailImage {
    return self.imageView.image;
}

- (void)setIsChosenAll:(BOOL)isChosenAll {
    [self.chosenImageView setImage:[UIImage imageNamed:@"status_select"]];
}

- (void)setIsChosen:(BOOL)isChosen {
    _isChosen = isChosen;
    [self.chosenImageView setImage:isChosen ? [UIImage imageNamed:@"status_select"] : [UIImage imageNamed:@"status_unselect"]];
}
@end
