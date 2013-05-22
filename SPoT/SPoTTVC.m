//
//  SPoTTVC.m
//  SPoT
//
//  Created by Marc Cuva on 4/14/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "SPoTTVC.h"
#import "FlickrFetcher.h"

@interface SPoTTVC () <UISplitViewControllerDelegate>
@property (strong, nonatomic) NSArray *flickrPhotos;
@property (strong, nonatomic) NSArray *flickrSections;
@end

@implementation SPoTTVC

- (IBAction) loadLatest {
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loader = dispatch_queue_create("Load photos", NULL);
    dispatch_async(loader, ^{
        NSArray* photos = [FlickrFetcher stanfordPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.flickrPhotos = photos;
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)viewDidLoad{
    [self.refreshControl addTarget:self
                            action:@selector(loadLatest) 
                  forControlEvents:UIControlEventValueChanged];
}

- (NSArray *)flickrPhotos{
    if(!_flickrPhotos) _flickrPhotos = [FlickrFetcher stanfordPhotos];
    return _flickrPhotos;
}

- (NSArray *)flickrSections{
    if(!_flickrSections){
        NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
        for(NSDictionary* photo in self.flickrPhotos){
            NSMutableArray* tags = [[photo[FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy];
            [tags removeObjectsInArray:@[@"cs193pspot", @"portrait", @"landscape"]];
            [set addObjectsFromArray:tags];
        }
        _flickrSections = [[NSArray alloc] initWithArray:[set sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2){
            return [obj1 compare:obj2];
        }]];
    }
    return _flickrSections;
}


#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.flickrSections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Section";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.flickrSections[indexPath.item] capitalizedString];
    int count = 0;
    for(NSDictionary* photo in self.flickrPhotos){
        if([[photo[FLICKR_TAGS] componentsSeparatedByString:@" "] containsObject:self.flickrSections[indexPath.item]]){
            count++;
        }
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photos", count];
    
    return cell;
}

#pragma mark - Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Photo List"]){
                if([segue.destinationViewController respondsToSelector:@selector(setTitle:)] &&
                   [segue.destinationViewController respondsToSelector:@selector(setFlickrPhotos:)] &&
                   [segue.destinationViewController respondsToSelector:@selector(setPhotoTag:)])
                {
                    NSString *title = self.flickrSections[indexPath.item];
                    [segue.destinationViewController setTitle:[title capitalizedString]];
                    [segue.destinationViewController performSelector:@selector(setFlickrPhotos:) withObject:self.flickrPhotos];
                    [segue.destinationViewController performSelector:@selector(setPhotoTag:) withObject:title];
                }
            }
        }
    }
}

@end
