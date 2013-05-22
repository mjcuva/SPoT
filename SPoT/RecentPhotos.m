//
//  RecentPhotos.m
//  SPoT
//
//  Created by Marc Cuva on 4/18/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "RecentPhotos.h"

@interface RecentPhotos ()
@end

@implementation RecentPhotos

#define ITEM_KEY @"Recent Photos"

+ (void)addPhoto:(NSDictionary *)photo{
    NSMutableArray *tempArray = [[self getRecentPhotos] mutableCopy];
    if([tempArray containsObject:photo]){
        [tempArray removeObject:photo];
    }
    [tempArray insertObject:photo atIndex:0];
    [self synchronizeWithNewArray:tempArray];
}

+ (NSArray *)getRecentPhotos{
    
    NSArray *recentPhotos = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:ITEM_KEY]];

    return recentPhotos;
    
}

+ (void)synchronizeWithNewArray:(NSArray *)newArray{
    if([newArray count] > 20){
        NSArray *newList = [[NSArray alloc] initWithArray:[newArray subarrayWithRange:NSMakeRange(0, 20)]];
        [[NSUserDefaults standardUserDefaults] setObject:newList forKey:ITEM_KEY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:ITEM_KEY];
    }
    

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
