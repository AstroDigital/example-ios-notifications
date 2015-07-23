//
//  DetailViewController.m
//  Notifications Viewer
//
//  Created by Joseph Flasher on 7/23/15.
//  Copyright (c) 2015 Development Seed. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property RMMapView *mapView;
@property NSOperationQueue *operationQueue;
@property NSDictionary *ADDict;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.operationQueue = [NSOperationQueue new];
    
    // Create info dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AstroDigital" ofType:@"plist"];
    self.ADDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [self configureView];
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        NSError *error;
        
        // Setup Mapbox instance
        [[RMConfiguration sharedInstance] setAccessToken:self.ADDict[@"mapboxToken"]];
        RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:self.ADDict[@"basemap"]];
        
        CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height * 0.5, self.view.frame.size.width, self.view.frame.size.height * 0.5);
        self.mapView = [[RMMapView alloc] initWithFrame:frame andTilesource:tileSource];
        NSDictionary *boundingBox = [NSJSONSerialization JSONObjectWithData:[self.detailItem[@"bounding_box"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        
        // Get coordinates for location
        float centerLon = ([boundingBox[@"coordinates"][0][0][0] floatValue] + [boundingBox[@"coordinates"][0][2][0] floatValue]) * 0.5;
        float centerLat = ([boundingBox[@"coordinates"][0][3][1] floatValue] + [boundingBox[@"coordinates"][0][1][1] floatValue]) * 0.5;
        [self.mapView setZoom:6 atCoordinate:CLLocationCoordinate2DMake(centerLat, centerLon) animated:NO];
        
        NSURL *imageURL = [NSURL URLWithString:self.detailItem[@"thumbnail"]];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
        [self.thumbnail setImage:[UIImage imageWithData:imageData]];
        self.sceneID.text = self.detailItem[@"scene_id"];
        self.date.text = self.detailItem[@"acquisition_date"];
        self.cloudCover.text = [NSString stringWithFormat:@"%@%%", self.detailItem[@"cloud_cover"]];
        
        // Add pin for notification center
        RMPointAnnotation *annotation = [[RMPointAnnotation alloc]
                                         initWithMapView:self.mapView
                                         coordinate:self.mapView.centerCoordinate
                                         andTitle:self.detailItem[@"scene_id"]];
        [self.mapView addAnnotation:annotation];
        
        [self.view addSubview:self.mapView];
        
        // Add action button
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(publishScene:)]];
        
        // Remove the title
        self.navigationItem.title = nil;
        
    }
}

#pragma mark - Alert Controller

- (void)publishScene:(id)sender {
    // Publish the scene using a selected processing method
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Let us know what processing method to use!" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *trueColor = [UIAlertAction actionWithTitle:@"True Color" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self makePublishAPICall:@"trueColor"];
    }];
    UIAlertAction *ndvi = [UIAlertAction actionWithTitle:@"NDVI" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self makePublishAPICall:@"ndvi"];
    }];
    UIAlertAction *urbanFalse = [UIAlertAction actionWithTitle:@"Urban False Color" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self makePublishAPICall:@"urbanFalse"];
    }];
    UIAlertAction *landWater = [UIAlertAction actionWithTitle:@"Land/Water Boundary" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self makePublishAPICall:@"landWater"];
    }];
    
    [alertController addAction:trueColor];
    [alertController addAction:ndvi];
    [alertController addAction:urbanFalse];
    [alertController addAction:landWater];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)makePublishAPICall:(NSString *)method {
    // Send call to API to publish scene at /publish
    NSString *urlString = [NSString stringWithFormat:@"%@publish", self.ADDict[@"baseURL"]];
    NSURL *dismissURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:dismissURL
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:30];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"satellite=l8&method=%@&email=test@test.com&sceneID=%@", method, self.detailItem[@"scene_id"]];
    [urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setValue:[NSString stringWithFormat:@"Token %@", self.ADDict[@"token"]] forHTTPHeaderField:@"Authorization"];

    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%@", response);
    }];
}

@end
