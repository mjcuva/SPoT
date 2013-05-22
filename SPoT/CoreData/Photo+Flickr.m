//
//  Photo+Flickr.m
//  SPoT
//
//  Created by Marc Cuva on 5/11/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Location+PlaceTook.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrData:(NSDictionary *)data inContext:(NSManagedObjectContext *)context{
    Photo *photo = nil;
    
    // Fetch Database to make sure unique
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique_id" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@", data[FLICKR_PHOTO_ID]];
    NSArray *photos = [context executeFetchRequest:request error:nil];
    
    if([photos count] == 1){
        photo = [photos lastObject];
    }else if([photos count] == 0){
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.name = [data[FLICKR_PHOTO_TITLE] description];
        photo.subtitle = [data[FLICKR_PHOTO_DESCRIPTION] description];
        photo.unique_id = [data[FLICKR_PHOTO_ID] description];
        photo.url_iphone = [[FlickrFetcher urlForPhoto:data format:FlickrPhotoFormatLarge] absoluteString];
        photo.url_ipad = [[FlickrFetcher urlForPhoto:data format:FlickrPhotoFormatOriginal] absoluteString];
        photo.url_square = [[FlickrFetcher urlForPhoto:data format:FlickrPhotoFormatSquare] absoluteString];
        
        
        NSMutableArray *locationCandidates = [[data[FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy];
        [locationCandidates removeObjectsInArray:@[@"cs193pspot", @"portrait", @"landscape"]];
        photo.placeTook = [Location locationWithName:locationCandidates[0] inManagedObjectContext:context];
    }
    
    return photo;
}

@end
