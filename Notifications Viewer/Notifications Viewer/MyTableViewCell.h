//
//  MyTableViewCell.m
//  Notifications Viewer
//
//  Created by Joseph Flasher on 9/17/15.
//  Copyright (c) 2015 Development Seed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *sceneID;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *cloudCover;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnail;

@end
