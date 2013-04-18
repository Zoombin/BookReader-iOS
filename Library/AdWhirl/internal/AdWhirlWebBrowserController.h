/*

 AdWhirlWebBrowserController.h

 Copyright 2009 AdMob, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdWhirlCustomAdView.h"

@class AdWhirlWebBrowserController;

@protocol AdWhirlWebBrowserControllerDelegate<NSObject>

- (void)webBrowserClosed:(AdWhirlWebBrowserController *)controller;

@end


@interface AdWhirlWebBrowserController : UIViewController <UIWebViewDelegate> {
  id<AdWhirlWebBrowserControllerDelegate> __unsafe_unretained delegate;
  UIViewController *__unsafe_unretained viewControllerForPresenting;
  NSArray *loadingButtons;
  NSArray *loadedButtons;
  AWCustomAdWebViewAnimType transitionType;

  UIWebView *webView;
  UIToolbar *toolBar;
  UIBarButtonItem *backButton;
  UIBarButtonItem *forwardButton;
  UIBarButtonItem *reloadButton;
  UIBarButtonItem *stopButton;
  UIBarButtonItem *linkOutButton;
  UIBarButtonItem *closeButton;
}

@property (nonatomic,unsafe_unretained) id<AdWhirlWebBrowserControllerDelegate> delegate;
@property (nonatomic,unsafe_unretained) UIViewController *viewControllerForPresenting;
@property (nonatomic,strong) IBOutlet UIWebView *webView;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *reloadButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *stopButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *linkOutButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *closeButton;

- (void)presentWithController:(UIViewController *)viewController transition:(AWCustomAdWebViewAnimType)animType;
- (void)loadURL:(NSURL *)url;
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)linkOut:(id)sender;
- (IBAction)close:(id)sender;

@end

@interface AdWhirlBackButton : UIBarButtonItem
@end

