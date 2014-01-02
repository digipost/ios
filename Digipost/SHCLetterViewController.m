//
//  SHCLetterViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import "SHCLetterViewController.h"
#import "SHCAttachment.h"

NSString *const kPushLetterIdentifier = @"PushLetter";

@interface SHCLetterViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SHCLetterViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"Loading %@", self.attachment.uri);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
