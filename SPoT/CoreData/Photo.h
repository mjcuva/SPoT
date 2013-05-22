//
//  Photo.h
//  SPoT
//
//  Created by Marc Cuva on 5/22/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * opened;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) NSString * url_ipad;
@property (nonatomic, retain) NSString * url_iphone;
@property (nonatomic, retain) NSString * url_square;
@property (nonatomic, retain) Location *placeTook;

@end
