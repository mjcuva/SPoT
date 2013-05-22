//
//  Cacher.m
//  SPoT
//
//  Created by Marc Cuva on 4/24/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "Cacher.h"

@implementation Cacher

+ (NSString *)cacheLocation{
    return [NSString stringWithFormat:@"%@/photos", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

+ (void) addImageToCacheWithData:(NSData*)imageData
                 andTitle:(NSString *)title{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    dispatch_queue_t saveQueue = dispatch_queue_create("save image", NULL);
    dispatch_async(saveQueue, ^{
        NSError *error = nil;
        NSMutableArray *files = [[fileManager contentsOfDirectoryAtPath:[self cacheLocation] error:&error] mutableCopy];
        while([files count] > 10){
            NSError *err = nil;
            NSUInteger index = [files count] - 1;
            BOOL worked = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [self cacheLocation], [files objectAtIndex:index]] error:&err];
            if(worked){
                [files removeObjectAtIndex:index];
            }
        }
        BOOL isDirectory;
        BOOL fileExists = [fileManager fileExistsAtPath:[self cacheLocation] isDirectory:&isDirectory];
        if(isDirectory && !fileExists){
            NSError *err = nil;
            [fileManager createDirectoryAtPath:[self cacheLocation] withIntermediateDirectories:NO attributes:nil error:&err];
        }
        [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@", [self cacheLocation], title] contents:imageData attributes:nil];
    });
}

+ (UIImage *)getImageWithTitle:(NSString *)title{
    NSData *imageData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self cacheLocation], title]];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

@end
