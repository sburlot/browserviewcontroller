//
//  BrowserViewController.h
//  Browser
//
//  Created by Stephan Burlot, Coriolis Technologies, http://www.coriolis.ch on 29.10.09.
//
// This work is licensed under the Creative Commons GNU General Public License License.
// To view a copy of this license, visit http://creativecommons.org/licenses/GPL/2.0/
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


@interface BrowserViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
	UIWebView *webView;
	NSURL *currentURL;
	UIToolbar *toolbar;
	
	BOOL hasToolbar;
	BOOL canOpenSafari;
	BOOL canRotateLandscape;

}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSURL *currentURL;
@property (nonatomic, assign) BOOL hasToolbar;
@property (nonatomic, assign) BOOL canOpenSafari;
@property (nonatomic, assign) BOOL canRotateLandscape;

- (id) initWithURL:(NSURL *)_baseUrl;

- (void) goBackHistory;
- (void) goFwdHistory;
- (void) stopLoading;
- (void) reloadWebview;
- (void) sendOrOpenCurrentPage;
- (void) fixToolbarButtons;
- (void) sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson;
- (void) openExternalURL:(NSURL *)externalURL;
- (void) showLoadingView;

@end
