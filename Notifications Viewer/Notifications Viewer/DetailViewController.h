//
//  DetailViewController.h
//  Notifications Viewer
//
//  Created by Joseph Flasher on 7/23/15.
//  Copyright (c) 2015 Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *sceneID;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *cloudCover;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

@end

