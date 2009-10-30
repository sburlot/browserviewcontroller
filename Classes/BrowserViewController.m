//
//  BrowserViewController.m
//  Browser
//
//  Created by Stephan Burlot, Coriolis Technologies, http://www.coriolis.ch on 29.10.09.
//
// This work is licensed under the Creative Commons GNU General Public License License.
// To view a copy of this license, visit http://creativecommons.org/licenses/GPL/2.0/
// or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
//

#import "BrowserViewController.h"

#define ACTION_SENDLINK 1
#define ACTION_OPEN_EXTERNAL 2

// From Joe Hewitt Three20
// http://github.com/joehewitt/three20

@implementation UIToolbar (Extras)

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag {
  for (UIBarButtonItem* button in self.items) {
    if (button.tag == tag) {
      return button;
    }
  }
  return nil;  
}

//==========================================================================================
- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item {
  NSInteger index = 0;
  for (UIBarButtonItem* button in self.items) {
    if (button.tag == tag) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.items];
      [newItems replaceObjectAtIndex:index withObject:item];
      self.items = newItems;
      break;
    }
    ++index;
  }  
}

@end

//==========================================================================================
@implementation BrowserViewController

@synthesize webView;
@synthesize toolbar;
@synthesize currentURL;
@synthesize externalURL;
@synthesize hasToolbar;
@synthesize canOpenSafari;
@synthesize canRotateLandscape;
@synthesize confirmBeforeExiting;

//==========================================================================================
- (id) initWithURL:(NSURL *)_baseURL
{
	if (self = [super init]) {
		self.currentURL = _baseURL;
		self.hasToolbar = TRUE;
		self.canOpenSafari = TRUE;
		self.canRotateLandscape = TRUE;
		self.confirmBeforeExiting = TRUE;
		[[Reachability sharedReachability] setHostName:[_baseURL host]];
	}
	return self;
}

//==========================================================================================
- (void)loadView 
{
	CGRect viewRect = [[UIScreen mainScreen] applicationFrame];
	
	UIView *contentView;
	
	contentView = [[UIView alloc] initWithFrame:viewRect];
	contentView.backgroundColor = [UIColor whiteColor];	
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
	self.view = contentView;
	[contentView release];
	
	if (hasToolbar) {
		self.toolbar = [UIToolbar new];
		toolbar.barStyle = UIBarStyleDefault;
		
		// size up the toolbar and set its frame
		[toolbar sizeToFit];
		CGFloat toolbarHeight = [toolbar frame].size.height;
		CGRect mainViewBounds = self.view.bounds;
		[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
																 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - toolbarHeight,
																 CGRectGetWidth(mainViewBounds),
																 toolbarHeight)];
		
		[self.view addSubview:toolbar];
		toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
		
		UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																																							target:nil
																																							action:nil];
		UIBarButtonItem *goBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"go_left.png"]
																																		 style:UIBarButtonItemStylePlain
																																		target:self
																																		action:@selector(goBackHistory)];
		goBackButton.tag = GOBACKBUTTON_TAG;
		UIBarButtonItem *goFwdButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"go_right.png"]
																																		style:UIBarButtonItemStylePlain
																																	 target:self
																																	 action:@selector(goFwdHistory)];
		goFwdButton.tag = GOFWDBUTTON_TAG;
		
		UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																																									target:self 
																																									action:@selector(reloadWebview)];
		reloadButton.tag = RELOADBUTTON_TAG;
		
		UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																																								target:self 
																																								action:@selector(sendOrOpenCurrentPage)];
		sendButton.tag = SENDBUTTON_TAG;
		
		NSArray *items = [NSArray arrayWithObjects: flexItem, goBackButton, flexItem, goFwdButton, flexItem, reloadButton, flexItem, sendButton, flexItem, nil];
		[self.toolbar setItems:items animated:NO];
		[flexItem release];
		[goBackButton release];
		[goFwdButton release];
		[reloadButton release];
		[sendButton release];
	}
	viewRect = self.view.bounds;
	
	if (hasToolbar)
		viewRect.size.height -= [toolbar frame].size.height;
	
	self.webView = [[UIWebView alloc] initWithFrame:viewRect];
	webView.delegate = self;
	webView.contentMode = UIViewContentModeTop;
	webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	webView.scalesPageToFit = NO;
	[self.view addSubview:webView];
	
}

//==========================================================================================
- (void)viewDidLoad
{
	MARK;
	NSURLRequest *req = [NSURLRequest requestWithURL:currentURL];
	[webView loadRequest:req];
//	[self showLoadingView];
	[super viewDidLoad];
}

//==========================================================================================
- (void)viewWillAppear:(BOOL)animated
{
	self.webView.delegate = self;	// setup the delegate as the web view is shown
}

//==========================================================================================
- (void)viewWillDisappear:(BOOL)animated
{
	[self.webView stopLoading];	// in case the web view is still loading its content
	self.webView.delegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//==========================================================================================
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (canRotateLandscape) {
		return TRUE;
	}
	
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//==========================================================================================
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

//==========================================================================================
- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

//==========================================================================================
- (void)dealloc
{
	self.webView = nil;
	self.currentURL = nil;
	self.externalURL = nil;
	self.toolbar = nil;
	[super dealloc];
}

//==========================================================================================
- (void) goBackHistory
{
	[webView stopLoading];
	[webView goBack];
}

//==========================================================================================
- (void) goFwdHistory
{
	[webView stopLoading];
	[webView goForward];
}

//==========================================================================================
- (void) stopLoading
{
	[webView stopLoading];	
}

//==========================================================================================
- (void) reloadWebview
{
	[webView stopLoading];
	[webView reload];
}

//==========================================================================================
- (void)sendOrOpenCurrentPage
{
	UIActionSheet *actionSheet;
	if (canOpenSafari) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Web Browser", nil)
																							delegate:self 
																		 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
																destructiveButtonTitle:nil
																		 otherButtonTitles:NSLocalizedString(@"Open with Safari", nil), NSLocalizedString(@"Send link via Email", nil), nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Web Browser", nil)
																							delegate:self 
																		 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
																destructiveButtonTitle:nil
																		 otherButtonTitles:NSLocalizedString(@"Send link via Email", nil), nil];
	}
	actionSheet.tag = ACTION_SENDLINK;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
	[actionSheet release];

}

//==========================================================================================
- (void) fixToolbarButtons
{
	if ([webView isLoading]) {
		UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
																																								 target:self 
																																								 action:@selector(stopLoading)];
		pauseButton.tag = RELOADBUTTON_TAG;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[toolbar replaceItemWithTag:RELOADBUTTON_TAG withItem:pauseButton];
		[pauseButton release];
	} else {
		UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																																									target:self 
																																									action:@selector(reloadWebview)];
		reloadButton.tag = RELOADBUTTON_TAG;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		[toolbar replaceItemWithTag:RELOADBUTTON_TAG withItem:reloadButton];
		[reloadButton release];
	}
	[[toolbar itemWithTag:GOFWDBUTTON_TAG] setEnabled:[webView canGoForward]];
	[[toolbar itemWithTag:GOBACKBUTTON_TAG] setEnabled:[webView canGoBack]];
}

//==========================================================================================
#pragma mark UIAlertView delegate
//==========================================================================================
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
			[self openExternalURL:externalURL];
}

//==========================================================================================
#pragma mark ActionSheet delegate
//==========================================================================================
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	switch (actionSheet.tag) {
		case ACTION_SENDLINK:
			if (canOpenSafari) {
				switch (buttonIndex) {
					case 0:	// Ouvrir dans Safari
						[[UIApplication sharedApplication] openURL:self.currentURL];
						break;
					case 1:	// Envoyer par email
						[self sendEmailWithSubject:@"" body:[currentURL absoluteString] to:@"" cc:@""];
						break;
					case 2: // Cancel
						break;
				}
			} else {
					switch (buttonIndex) {
						case 0:	// Envoyer par email
							[self sendEmailWithSubject:@"" body:[currentURL absoluteString] to:@"" cc:@""];
							break;
						case 1: // Cancel
							break;
					}
			}
			break;
		case ACTION_OPEN_EXTERNAL:
			break;
	}
}
	
//==========================================================================================
#pragma mark Mail stuff
//==========================================================================================
- (void) sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson
{
	NetworkStatus internetConnectionStatus;
	NetworkStatus remoteHostStatus;
	
	remoteHostStatus         = [[Reachability sharedReachability] remoteHostStatus];
	internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
	if ((internetConnectionStatus == NotReachable) && (remoteHostStatus == NotReachable)) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
																										message:NSLocalizedString(@"You have no internet connection.", nil) 
																									 delegate:nil 
																					cancelButtonTitle:NSLocalizedString(@"OK", nil) 
																					otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
#if	!TARGET_IPHONE_SIMULATOR
	if (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
																										message:NSLocalizedString(@"Your iPhone is not configured to send emails.", nil) 
																									 delegate:nil 
																					cancelButtonTitle:NSLocalizedString(@"OK", nil) 
																					otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
#endif
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:[NSArray arrayWithObject:toPerson]];
	[picker setCcRecipients:[NSArray arrayWithObject:ccPerson]];
	[picker setSubject:subject];
	
	[picker setMessageBody:body isHTML:NO];
	
	picker.navigationBar.tintColor = [UIColor blackColor];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

//==========================================================================================
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	NSString *alertMessage = nil;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			alertMessage = NSLocalizedString(@"Your message has been sent.", nil);
			break;
		case MFMailComposeResultFailed:
			alertMessage = NSLocalizedString(@"Your message could not be sent.", nil);
			break;
		default:
			alertMessage = NSLocalizedString(@"Your message could not be sent.", nil);
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
	if (alertMessage != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sending Email", nil) 
																										message:alertMessage 
																									 delegate:nil 
																					cancelButtonTitle:NSLocalizedString(@"OK", nil)
																					otherButtonTitles:nil,nil];
		[alert show];
		[alert release];
	}
	
}

//==========================================================================================
- (void) sendMailWithURL:(NSURL *)url
{
	// method to split an url "mailto:sburlot@coriolis.ch?cc=info@coriolis.ch&subject=Hello%20From%20iPhone&body=The message's first paragraph.%0A%0aSecond paragraph.%0A%0AThird Paragraph."
	// into separate elements

	NSString *toPerson = @"";
	NSString *ccPerson = @"";;
	NSString *subject = @"";
	NSString *body = @"";

	NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
	[urlString replaceOccurrencesOfString:@"mailto:" withString:@"" options:0 range:NSMakeRange(0, [urlString length])];
	
	if ([urlString rangeOfString:@"?"].location != NSNotFound) {
		toPerson = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
		NSString *query = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
		
		if (query && [query length]) {
			NSArray *itemsOfURL = [query componentsSeparatedByString:@"&"];
			for (NSString *queryItem in itemsOfURL) {
				NSArray *queryElements = [queryItem componentsSeparatedByString:@"="];
				CMLog(@"queryElements: %@", queryElements);
				if ([[queryElements objectAtIndex:0] isEqualToString:@"to"])
					toPerson = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"cc"])
					ccPerson = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"subject"])
					subject = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"body"])
					body = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			}
		}
	} else {
		toPerson = urlString;
	}

	CMLog(@"to: %@", toPerson);
	CMLog(@"cc: %@", ccPerson);
	CMLog(@"subject: %@", subject);
	CMLog(@"body: %@", body);
	[self sendEmailWithSubject:subject body:body to:toPerson cc:ccPerson];

}

//==========================================================================================
#pragma mark Handle links (iTunes, Phobos, YouTube, Maps)
// https://developer.apple.com/iphone/library/qa/qa2008/qa1629.html
//==========================================================================================
// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openExternalURL:(NSURL *)_externalURL
{
	self.currentURL = _externalURL;
	[self performSelector:@selector(showLoadingView) withObject:nil afterDelay:0.2];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:_externalURL] 
																													delegate:self 
																									startImmediately:YES];
	[conn release];
}

//==========================================================================================
// Save the most recent URL in case multiple redirects occur
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
	if (response)
		self.currentURL = [response URL];
	return request;
}

//==========================================================================================
// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[UIApplication sharedApplication] openURL:self.currentURL];
}

//==========================================================================================
- (void) confirmBeforeOpeningURL:(NSURL *)_externalURL withMessage:(NSString *)msg
{
	self.externalURL = _externalURL;
	if (confirmBeforeExiting) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
																										message:msg
																									 delegate:self 
																					cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
																					otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alert show];
		[alert release];
	} else {
		[self openExternalURL:_externalURL];
	}
}

//==========================================================================================
- (void) showLoadingView
{
	MARK;
	UIView *loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
	loadingView.tag = LOADINGVIEW_TAG;
	loadingView.alpha = 0.8;
	loadingView.opaque = NO;
	loadingView.backgroundColor = [UIColor darkGrayColor];

	loadingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(142.0, 222.0, 37.0, 37.0)];
	progressView.center = loadingView.center;
	progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	[progressView startAnimating];
	progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[loadingView addSubview:progressView];
	[self.view addSubview:loadingView];
	[loadingView release];
	[progressView release];
}

//==========================================================================================
#pragma mark UIWebView delegates
//==========================================================================================
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType
{
	MARK;
	
	NSURL *url = [req URL];

	if ([[url scheme] isEqualToString:@"mailto"]) {
		[self sendMailWithURL:url];
		return NO;
	}
	
	if ([[url host] isEqualToString:@"phobos.apple.com"] || [[url host] isEqualToString:@"itunes.apple.com"]) {
		[self confirmBeforeOpeningURL:url withMessage:NSLocalizedString(@"You are opening iTunes", nil)];
		return NO;
	}
	
	if ([[url host] rangeOfString:@"youtube.com"].location != NSNotFound) {
		[self confirmBeforeOpeningURL:url withMessage:NSLocalizedString(@"You are opening YouTube", nil)];
//		[[UIApplication sharedApplication] openURL: url];
		return NO;
	}

	if ([[url host] rangeOfString:@"maps.google."].location != NSNotFound) {
		[self confirmBeforeOpeningURL:url withMessage:NSLocalizedString(@"You are opening Map", nil)];
		//		[[UIApplication sharedApplication] openURL: url];
		return NO;
	}
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}

	[self fixToolbarButtons];
	return YES;
}

//==========================================================================================
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (([error code] != 102) && ([error code] != NSURLErrorCancelled)) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) 
																										message:NSLocalizedString(@"Error while loading the page. Please try again.", nil) 
																									 delegate:nil 
																					cancelButtonTitle:NSLocalizedString(@"OK", nil) 
																					otherButtonTitles:nil];
		[alert show];
		[alert release];
		UIView *view = [self.view viewWithTag:LOADINGVIEW_TAG];
		if (view) 
			[view removeFromSuperview];
	}
	[self fixToolbarButtons];
}

//==========================================================================================
- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
	self.currentURL = _webView.request.URL;
	self.title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self fixToolbarButtons];
}

//==========================================================================================
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self fixToolbarButtons];
}

@end
