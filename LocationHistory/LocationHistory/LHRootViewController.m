//
//  LHRootViewController.m
//  LocationHistory
//
//  Created by Hidetoshi Mori on 13/04/21.
//  Copyright (c) 2013年 Hidetoshi Mori. All rights reserved.
//

#import "LHRootViewController.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"

@interface LHRootViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)createNoteAction:(UIButton *)sender;

@end

@implementation LHRootViewController {
    CLLocationManager *_locationManager;
    CLLocation * _currentLocation;
    NSString *_addressString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];

    [self startEvernoteSession];
}

#pragma mark - Action methods

- (IBAction)createNoteAction:(UIButton *)sender {
    [self createNote];
}

#pragma mark - Private methods

- (void)appendText:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.textView.text, text];
}

#pragma mark - Evernote API Process

- (void)startEvernoteSession {
    EvernoteSession *session = [EvernoteSession sharedSession];
    [self appendText:[NSString stringWithFormat:@"start Evernote Authorication"]];
    [self appendText:[NSString stringWithFormat:@"Session host: %@", [session host]]];
    [self appendText:[NSString stringWithFormat:@"Session key: %@", [session consumerKey]]];
    [self appendText:[NSString stringWithFormat:@"Session secret: %@", [session consumerSecret]]];
    
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated){
            if (error) {
                [self appendText:[NSString stringWithFormat:@"Error authenticating with Evernote Cloud API: %@", error]];
            }
            if (!session.isAuthenticated) {
                [self appendText:[NSString stringWithFormat:@"Session not authenticated"]];
            }
        } else {
            EvernoteUserStore *userStore = [EvernoteUserStore userStore];
            [userStore getUserWithSuccess:^(EDAMUser *user) {
                [self appendText:[NSString stringWithFormat:@"-- Authenticated as %@", [user username]]];
            } failure:^(NSError *error) {
                [self appendText:[NSString stringWithFormat:@"-- Error getting user: %@", error]];
            } ];
        }
    }];
}

- (void)createNote {
    
    static NSString *enmlTemplate = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\"><en-note>%@</en-note>";
    
    CLLocationDegrees lat = _currentLocation.coordinate.latitude;
    CLLocationDegrees lon = _currentLocation.coordinate.longitude;
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%f,%f&amp;zoom=17&amp;markers=label:A|%f,%f&amp;size=500x300&amp;sensor=true",
                              lat, lon, lat, lon];
    NSString *linkUrl = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f", lat, lon];
    NSString *location = [NSString stringWithFormat:@"<a href='%@'>%@ (%f,%f)</a>", linkUrl, _addressString, lat, lon];
    NSString *content = [NSString stringWithFormat:@"%@<br/><img src='%@'/>", location, staticMapUrl];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSString *title = [NSString stringWithFormat:@"LocationHistory [%@]: %@", [formatter stringFromDate:[NSDate date]], _addressString];
    
    EDAMNote *note = [[EDAMNote alloc] init];
    note.title = title;
    note.tagNames = [NSArray arrayWithObject:@"LocationHistory"];
    note.content = [NSString stringWithFormat:enmlTemplate, content];
    
    __block LHRootViewController *weakSelf = self;
    [[EvernoteNoteStore noteStore]
     createNote:note
     success:^(EDAMNote *note) {
         [weakSelf appendText:[NSString stringWithFormat:@"Created note : %@", title]];
         [[[UIAlertView alloc] initWithTitle:@"Complete" message:@"Success created note." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] show];
     }
     failure:^(NSError *error) {
         [weakSelf appendText:[NSString stringWithFormat:@"Error : %@", error.description]];
     }];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    if (abs([newLocation.timestamp timeIntervalSinceNow]) > 15.0f) {
        return;
    }
    if (newLocation.horizontalAccuracy > kCLLocationAccuracyNearestTenMeters) {
        return;
    }
    
    _currentLocation = newLocation;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error){
            for (CLPlacemark *placemark in placemarks) {
                _addressString = [NSString stringWithFormat:@"%@%@%@",
                                  placemark.administrativeArea,
                                  placemark.locality,
                                  placemark.name];
                [self appendText:[NSString stringWithFormat:@"address : %@", _addressString]];
            }
        }
    }];
    [self appendText:[NSString stringWithFormat:@"location [%f]: (%f,%f)", _currentLocation.horizontalAccuracy, _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude]];
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    
}



@end
