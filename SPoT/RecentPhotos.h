//
//  RecentPhotos.h
//  SPoT
//
//  Created by Marc Cuva on 4/18/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//
//  Model for Recent Images

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject

@property (nonatomic, readonly) NSArray *recentPhotos;

+ (void) addPhoto:(NSDictionary *)photo;
+ (NSArray *)getRecentPhotos;

@end
