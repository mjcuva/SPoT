//
//  PhotoListTVC.m
//  SPoT
//
//  Created by Marc Cuva on 4/14/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "PhotoListTVC.h"
#import "FlickrFetcher.h"
#import "RecentPhotos.h"

@interface PhotoListTVC () <UISplitViewControllerDelegate>
@property (strong, nonatomic) NSArray* sectionPhotos;
@end

@implementation PhotoListTVC

- (NSArray *)sectionPhotos{
    if(!_sectionPhotos){
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for(NSDictionary *photo in self.flickrPhotos){
            if([[photo[FLICKR_TAGS] componentsSeparatedByString:@" "] containsObject:self.photoTag]){
                [temp addObject:photo];
            }
        }
        _sectionPhotos = [[NSArray alloc] initWithArray:temp];
    }
    return _sectionPhotos;
}

- (NSArray *)flickrPhotos{
    if(!_flickrPhotos) _flickrPhotos = [FlickrFetcher stanfordPhotos];
    return _flickrPhotos;
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sectionPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.sectionPhotos[indexPath.item][FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [self.sectionPhotos[indexPath.item] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Image"]){
                if([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]){
                    FlickrPhotoFormat photoFormat;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                        photoFormat = FlickrPhotoFormatOriginal;
                    }else{
                        photoFormat = FlickrPhotoFormatLarge;
                    }
                    NSURL *url = [FlickrFetcher urlForPhoto:self.sectionPhotos[indexPath.item] format:photoFormat];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:self.sectionPhotos[indexPath.item][FLICKR_PHOTO_TITLE]];
                    [RecentPhotos addPhoto:self.sectionPhotos[indexPath.item]];
                }
            }
        }
    }
}

@end
