//
//  AlbumService.m
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import "AlbumService.h"
#import <Photos/Photos.h>

@interface AlbumService() <PHPhotoLibraryChangeObserver>

@end

@implementation AlbumService

+ (instancetype)share {
    static AlbumService *albumService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumService = [[AlbumService alloc]init];
    });
    return albumService;
}

- (NSArray *)getAllPhotos {
    NSMutableArray *arr = [NSMutableArray array];
    // 所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (NSInteger i = 0; i < smartAlbums.count; i++) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        PHCollection *collection = smartAlbums[i];
        // 遍历获取相册
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            NSLog(@"相册 %@", collection.localizedTitle);
            if ([collection.localizedTitle isEqualToString:@"All Photos"]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                NSArray *assets;
                if (fetchResult.count > 0) {
                    // 某个相册里面的所有PHAsset对象
                    assets = [self getAllPhotosAssetInAblumCollection:assetCollection ascending:YES ];
                    [arr addObjectsFromArray:assets];
                }
            }
        }
    }
    return arr;
}

#pragma mark - <  获取相册里的所有图片的PHAsset对象  >
- (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    // 存放所有图片对象
    NSMutableArray *assets = [NSMutableArray array];
    
    // 是否按创建时间排序
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 获取所有图片对象
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    // 遍历
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:asset];
    }];
    return assets;
}

- (void)photoLibraryDidChange:(nonnull PHChange *)changeInstance {
    
}

@end
