//
//  MasterViewController.m
//  Notifications Viewer
//
//  Created by Joseph Flasher on 7/23/15.
//  Copyright (c) 2015 Development Seed. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MyTableViewCell.h"
#import "AddAlertViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@property NSOperationQueue *operationQueue;
@property NSDictionary *ADDict;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"My New Notifications";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAlert:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.operationQueue = [NSOperationQueue new];
    
    // Create info dictionary for AD information
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AstroDigital" ofType:@"plist"];
    self.ADDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    // Grab all the notifications from /notifications
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@notifications", self.ADDict[@"baseURL"]]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:30];
    [urlRequest setValue:[NSString stringWithFormat:@"Token %@", self.ADDict[@"token"]] forHTTPHeaderField:@"Authorization"];
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:&error];
    self.objects = [[NSMutableArray alloc] initWithArray:json[@"results"]];

    // Filter out dismissed notifications
    for (int i = 0; i < self.objects.count; i++) {
        if ([[self.objects objectAtIndex:i][@"dismissed"] boolValue]) {
            [self.objects removeObjectAtIndex:i];
        }
    }
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)addAlert:(id)sender {
    // Show the add alert view controller
    AddAlertViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddAlert"];
    [vc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = (MyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *notification = self.objects[indexPath.row];
    cell.sceneID.text = notification[@"scene_id"];
    cell.date.text = notification[@"acquisition_date"];
    cell.cloudCover.text = [NSString stringWithFormat:@"%@%%", notification[@"cloud_cover"]];
    [cell.thumbnail setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:notification[@"thumbnail"]]]]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Grab id to use later
        NSInteger notificationID = [[self.objects objectAtIndex:indexPath.row][@"id"] integerValue];
        
        // Remove from list
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Send call to API to dismiss notification at /id/dismiss
        NSString *urlString = [NSString stringWithFormat:@"%@notifications/%i/dismiss", self.ADDict[@"baseURL"], (int)notificationID];
        NSURL *dismissURL = [NSURL URLWithString:urlString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:dismissURL
                                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                              timeoutInterval:30];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:[NSString stringWithFormat:@"Token %@", self.ADDict[@"token"]] forHTTPHeaderField:@"Authorization"];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSLog(@"%@", response);
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Dismiss";
}

@end
