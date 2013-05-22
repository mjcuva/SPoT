//
//  RecentCDTVC.m
//  SPoT
//
//  Created by Marc Cuva on 5/22/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "RecentCDTVC.h"
#import "Photo+Flickr.h"

@interface RecentCDTVC () <UISplitViewControllerDelegate>

@end

@implementation RecentCDTVC

#pragma mark - Model

- (void)setContext:(NSManagedObjectContext *)context{
    _context = context;
    if(context){
        [self reload];
    }else{
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Recent Item"];
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

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!self.context){
        [self useDocument];   
    }else{
        [self reload];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.fetchedResultsController = nil;
}

- (void)awakeFromNib{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
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

- (void)reload{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"opened" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"opened != nil"];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Image"]){
                Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                photo.opened = [NSDate date];
                NSURL *url;
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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


@end
