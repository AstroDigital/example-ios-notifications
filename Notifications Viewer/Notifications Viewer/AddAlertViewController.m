//
//  AddAlertViewController.m
//  Notifications Viewer
//
//  Created by Joseph Flasher on 9/18/15.
//  Copyright (c) 2015 Development Seed. All rights reserved.
//

#import "AddAlertViewController.h"
#import "Mapbox.h"

@interface AddAlertViewController ()

@property RMMapView *mapView;
@property IBOutlet UITextField *nameField;
@property NSDictionary *ADDict;
@property NSOperationQueue *operationQueue;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@end

@implementation AddAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create info dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AstroDigital" ofType:@"plist"];
    self.ADDict = [[NSDictionary alloc] initWithContentsOfFile:path];

    // Set up Mapbox instance
    [[RMConfiguration sharedInstance] setAccessToken:self.ADDict[@"mapboxToken"]];
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:self.ADDict[@"basemap"]];
    
    UIView *mapHolder = [self.view viewWithTag:10];
    self.mapView = [[RMMapView alloc] initWithFrame:mapHolder.frame andTilesource:tileSource];
    self.mapView.showsUserLocation = YES;
    self.mapView.showLogoBug = NO;
    // Start with default coordinate, it'll get overwritten with user's location
    [self.mapView setZoom:1 atCoordinate:CLLocationCoordinate2DMake(0, 0) animated:NO];
    
    [self.view addSubview:self.mapView];
    
    self.operationQueue = [NSOperationQueue new];
    
    // Ask for location updates
    [self startStandardUpdates];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createAlert:(id)sender {
    NSError *error;
    
    // Send call to API to create an Alert at /alerts
    NSString *urlString = [NSString stringWithFormat:@"%@alerts", self.ADDict[@"baseURL"]];
    NSURL *alertURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:alertURL
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:30];
    [urlRequest setHTTPMethod:@"POST"];
    
    // Create the object to post, we're going to make this JSON and then turn it into a string
    NSString *nameText = [self.nameField.text isEqualToString:@""] ? self.nameField.placeholder : self.nameField.text;
    NSDictionary *postDict = @{@"name": nameText, @"query": @{@"contains": [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude]}};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:&error];
    NSString *postString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setValue:[NSString stringWithFormat:@"Token %@", self.ADDict[@"token"]] forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // And send it!
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%@", response);
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        // Add an alert to know we succeeded
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Success" message:@"You will receive notifications when there is new imagery in this area on the platform!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Dismiss the modal now that we're all done
            [self cancel:nil];
        }];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }];
}

# pragma mark - Location updates

- (void)startStandardUpdates {
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    
    // If it's accurate to within 500m, we can stop updating for now
    if (location.horizontalAccuracy < 500) {
        [self.locationManager stopUpdatingLocation];
        
        self.currentLocation = location;
        
        // Center map on our location
        [self.mapView setZoom:10 atCoordinate:location.coordinate animated:YES];
        
        // Add new placeholder to text field
        NSString *placeholder = [NSString stringWithFormat:@"My Alert at %.2f, %.2f", location.coordinate.latitude, location.coordinate.longitude];
        [self.nameField setPlaceholder:placeholder];
    }
}




@end
