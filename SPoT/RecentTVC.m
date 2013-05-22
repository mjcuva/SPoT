//
//  RecentTVC.m
//  SPoT
//
//  Created by Marc Cuva on 4/18/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "RecentTVC.h"
#import "FlickrFetcher.h"
#import "RecentPhotos.h"

@interface RecentTVC ()
@property (strong, nonatomic) NSArray *recentList;
@end

@implementation RecentTVC

- (NSArray *)recentList{
    _recentList = [RecentPhotos getRecentPhotos];
    return _recentList;
}

- (void) viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.recentList[indexPath.item][FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [self.recentList[indexPath.item] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

#pragma mark - Seque

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Image"]){
                if([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]){
                    NSURL *url = [FlickrFetcher urlForPhoto:self.recentList[indexPath.item] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:self.recentList[indexPath.item][FLICKR_PHOTO_TITLE]];
                }
            }
        }
    }
}


@end
