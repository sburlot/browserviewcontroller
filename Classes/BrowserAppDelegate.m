//
//  BrowserAppDelegate.m
//  Browser
//
//  Created by Stephan Burlot, Coriolis Technologies, http://www.coriolis.ch on 29.10.09.
//
// This work is licensed under the Creative Commons GNU General Public License License.
// To view a copy of this license, visit http://creativecommons.org/licenses/GPL/2.0/
// or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
//
//

#import "BrowserAppDelegate.h"
#import "BrowserViewController.h"

#define WITH_NAV_CONTROLLER
#define WITH_TOOLBAR

@implementation BrowserAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	viewController = [[BrowserViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.coriolis.ch/browsertest.html"]];
#ifndef WITH_TOOLBAR
	viewController.hasToolbar = FALSE;
#endif
	
#ifdef WITH_NAV_CONTROLLER
	navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[window addSubview:navController.view];
#else
	[window addSubview:viewController.view];
#endif
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	[navController release];
	[viewController release];
	[window release];
	[super dealloc];
}

@end
