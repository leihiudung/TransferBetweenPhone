//
//  AlbumCollectionViewCell.h
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSString *representedAssetIdentifier;

@property (nonatomic, strong) UIImage *thumbnailImage;

- (void)initCellData:(UIImage *)image;
- (void)initCellDataWith:(PHAsset *)phAsset;
@end

NS_ASSUME_NONNULL_END
