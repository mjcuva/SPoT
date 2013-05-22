//
//  Location+PlaceTook.h
//  SPoT
//
//  Created by Marc Cuva on 5/11/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "Location.h"

@interface Location (PlaceTook)

+ (Location *)locationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
