//
//  Cacher.h
//  SPoT
//
//  Created by Marc Cuva on 4/24/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cacher : NSObject

+ (void) addImageToCacheWithData:(NSData *)imageData andTitle:(NSString *)title;
+ (UIImage *)getImageWithTitle:(NSString *)title;

@end
