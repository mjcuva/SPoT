//
//  PhotosCDTVC.h
//  SPoT
//
//  Created by Marc Cuva on 5/15/13.
//  Copyright (c) 2013 Marc Cuva. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Location.h"

@interface PhotosCDTVC : CoreDataTableViewController
@property (strong, nonatomic) Location *location;
@end
