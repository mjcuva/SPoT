//
//  LocationCDTVC.m
//  SPoT
//
//  Created by Marc Cuva on 5/11/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "LocationCDTVC.h"
#import "Location.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@interface LocationCDTVC() <UISplitViewControllerDelegate>

@end

@implementation LocationCDTVC 

#pragma mark - Model

- (void) setContext:(NSManagedObjectContext *)context{
    _context = context;
    if(context){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil; // all
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    }else{
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [location.photos count]];
    
    return cell; 
}

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.context) [self useDocument];
}

- (void)awakeFromNib{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

- (void)useDocument{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Flickr Data"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if(success){
                self.context = document.managedObjectContext;
                [self refresh];
            }
        }];
    }else if(document.documentState == UIDocumentStateClosed){
        [document openWithCompletionHandler:^(BOOL success){
            if(success){
                self.context = document.managedObjectContext;
            }
        }];
    }else{
        self.context = document.managedObjectContext;
    }
}


#pragma mark - Refresh

-(IBAction)refresh{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loader = dispatch_queue_create("Load photos", NULL);
    dispatch_async(loader, ^{
        NSArray* photos = [FlickrFetcher stanfordPhotos];
        [self.context performBlock:^{
            for(NSDictionary *photo in photos){
                [Photo photoWithFlickrData:photo inContext:self.context];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSIndexPath *indexPath = nil;
    
    if([sender isKindOfClass:[UITableViewCell class]]){
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if(indexPath){
        if([segue.identifier isEqualToString:@"Show Photo List"]){
            Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if([segue.destinationViewController respondsToSelector:@selector(setLocation:)]){
                [segue.destinationViewController performSelector:@selector(setLocation:) withObject:location];
            }
        }
    }
}




@end
