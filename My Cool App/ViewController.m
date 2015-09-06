//
//  ViewController.m
//  My Cool App
//
//  Created by David Carr on 9/6/15.
//  Copyright (c) 2015 David Carr. All rights reserved.
//

#import "ViewController.h"

#import <AddressBook/AddressBook.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) NSMutableArray* contacts;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4
                NSLog(@"Just denied");
                return;
            }
            //5
            NSLog(@"Just authorized");
            
            [self loadContacts];
        });
    }
    
    [self loadContacts];
}

- (void) loadContacts {
    ABAddressBookRef addressBook = ABAddressBookCreate( );
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    
    NSLog(@"number = %ld", nPeople);
    
    _contacts = [[NSMutableArray alloc] init];
    [_contacts removeAllObjects];
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        NSDictionary* dict = @{
                               @"first": firstName,
                               @"last": lastName
                               };
        
        NSLog(@"%@ %@", firstName, lastName);
        
        [_contacts insertObject:dict atIndex:[_contacts count]];
    }
    
    [_table reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"size = %ld", [_contacts count]);
    return [_contacts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary* contact = [_contacts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[contact[@"first"] stringByAppendingString:@" "] stringByAppendingString: contact[@"last"]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
