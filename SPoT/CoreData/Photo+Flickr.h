//
//  Photo+Flickr.h
//  SPoT
//
//  Created by Marc Cuva on 5/11/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrData:(NSDictionary *)data inContext:(NSManagedObjectContext *)context;

@end
