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

@implementation BrowserAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	viewController = [[BrowserViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.coriolis.ch/browsertest.html"]];
	viewController.hasToolbar = YES;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[window addSubview:navController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	[viewController release];
	[window release];
	[super dealloc];
}

@end
