//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Peter Shultz on 12/8/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView* webView;

@end

@implementation LoginViewController

NSString* const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

- (NSString*) redirectURI
{
    return @"http://www.petershultz.com";
}

- (void) loadView
{
    UIWebView* webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonSystemItemEdit target:self action:@selector(homePressed:)];
    self.navigationItem.rightBarButtonItem = newButton;

    
    self.webView = webView;
    self.view = webView;
}

- (IBAction)homePressed:(id)sender
{
    [self setUpLogin];
}


- (void) dealloc
{
    [self clearInstagramCookies];
    
    //Apple documentation says so
    self.webView.delegate = nil;
}

- (void) clearInstagramCookies
{
    for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        
        if (domainRange.location != NSNotFound)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:[self redirectURI]])
    {
        //Contains auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString* accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    
    return YES;
}

- (void)setUpLogin
{
    
    NSString* urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL* url = [NSURL URLWithString:urlString];
    
    
    if (url)
    {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpLogin];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
