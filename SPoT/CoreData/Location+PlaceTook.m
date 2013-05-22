//
//  Location+PlaceTook.m
//  SPoT
//
//  Created by Marc Cuva on 5/11/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "Location+PlaceTook.h"

@implementation Location (PlaceTook)

+ (Location *)locationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context{
    Location *location = nil;
    name = [name capitalizedString];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSArray *locations = [context executeFetchRequest:request error:nil];
    
    if([locations count] == 1){
        location = [locations lastObject];
    }else if(![locations count]){
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
        location.name = name;
    }
    
    return location;
}

@end
