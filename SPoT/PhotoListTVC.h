//
//  PhotoListTVC.h
//  SPoT
//
//  Created by Marc Cuva on 4/14/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListTVC : UITableViewController
@property (strong, nonatomic) NSArray *flickrPhotos;
@property (strong, nonatomic) NSString *photoTag;
@end
