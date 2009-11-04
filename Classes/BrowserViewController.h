//
//  BrowserViewController.h
//  Browser
//
//  Created by Stephan Burlot, Coriolis Technologies, http://www.coriolis.ch on 29.10.09.
//
// This work is licensed under the Creative Commons Attribution License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
// or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define GOBACKBUTTON_TAG 1
#define GOFWDBUTTON_TAG 2
#define RELOADBUTTON_TAG 3
#define SENDBUTTON_TAG 4

#define LOADINGVIEW_TAG 333

@interface UIToolbar (Extras)

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag;

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item;

@end


@interface BrowserViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
	UIWebView *webView;
	NSURL *currentURL;
	UIToolbar *toolbar;
	NSURL *externalURL;
	
	BOOL hasToolbar;		// do we need a toolbar, safari like?
	BOOL canOpenSafari;	// can we open the current page in Safari?
	BOOL canRotateLandscape;	// can we rotate?
	BOOL confirmBeforeExiting;	// need confirmation before exiting the app?

}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSURL *currentURL;
@property (nonatomic, retain) NSURL *externalURL;
@property (nonatomic, assign) BOOL hasToolbar;
@property (nonatomic, assign) BOOL canOpenSafari;
@property (nonatomic, assign) BOOL canRotateLandscape;
@property (nonatomic, assign) BOOL confirmBeforeExiting;

- (id) initWithURL:(NSURL *)_baseUrl;

- (void) goBackHistory;
- (void) goFwdHistory;
- (void) stopLoading;
- (void) reloadWebview;
- (void) sendOrOpenCurrentPage;
- (void) fixToolbarButtons;
- (void) sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson;
- (void) showYouTubeVideoInline:(NSURL *)url;
- (void) confirmBeforeOpeningURL:(NSURL *)externalURL withMessage:(NSString *)msg;
- (void) openExternalURL:(NSURL *)externalURL;
- (void) showLoadingView;

@end

