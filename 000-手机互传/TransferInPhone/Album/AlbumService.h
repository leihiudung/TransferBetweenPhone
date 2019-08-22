//
//  AlbumService.h
//  000-手机互传
//
//  Created by Tom-Li on 2019/8/21.
//  Copyright © 2019 Dong&Ling. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photos;

@interface AlbumService : NSObject
+ (instancetype)share;
- (NSArray *)getAllPhotos;
@end

