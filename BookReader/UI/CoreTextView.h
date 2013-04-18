//
//  CoreTextView.h
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

@interface CoreTextView : UIView

- (void)buildTextWithString:(NSString *)string;
- (void)loadMutableFonts;
@end
