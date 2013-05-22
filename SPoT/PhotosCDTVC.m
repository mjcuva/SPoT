//
//  PhotosCDTVC.m
//  SPoT
//
//  Created by Marc Cuva on 5/15/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"
#import "FlickrFetcher.h"

@interface PhotosCDTVC ()

@end

@implementation PhotosCDTVC

- (void)setLocation:(Location *)location{
    _location = location;
    self.title = location.name;
    [self setUpController];
}

- (void)setUpController{
    if(self.location.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"placeTook = %@", self.location];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.location.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }else{
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.name;
    cell.detailTextLabel.text = photo.subtitle;
        
    NSData *data;
    if(!photo.thumbnail){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.url_square]];
        photo.thumbnail = data;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }else{
        data = photo.thumbnail;
    }
    cell.imageView.image = [[UIImage alloc] initWithData:data];

                   
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Image"]){
                if([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]){
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    photo.opened = [NSDate date];
                    NSURL *url;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                        url = [NSURL URLWithString:[photo url_ipad]];
                    }else{
                        url = [NSURL URLWithString:[photo url_iphone]];
                    }
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[photo name]];
                    
                }
            }
        }
    }
}

@end
