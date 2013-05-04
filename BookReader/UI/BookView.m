//
//  BookView.m
//  BookReader
//
//  Created by 颜超 on 13-4-14.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookView.h"
#import "CustomProgressView.h"
#import "UIDefines.h"
#import "MKNumberBadgeView.h"
#import "ServiceManager.h"
#import "UIImageView+AFNetworking.h"
#import "BookReaderDefaultManager.h"

#define BOOK_WIDTH                        72
#define BOOK_HEIGHT                       99
#define PROGRESS_BOOK_OFFSET              4

#define CHECKMARKWIDTH                    28
#define CHECKMARKHEIGHT                   29

#define BADGEWIDTH                        80
#define BADGEHEIGHT                       23

#define BACKGROUNDBUTTONFRAME  CGRectMake(0, 0, BOOK_WIDTH*SCREEN_SCALE, BOOK_HEIGHT*SCREEN_SCALE+PROGRESS_BOOK_OFFSET*SCREEN_SCALE)     
#define CUSTOMPROGRESSVIEWFRAME CGRectMake(0,backgroundButton.frame.size.height+PROGRESS_BOOK_OFFSET*SCREEN_SCALE, BOOK_WIDTH*SCREEN_SCALE, 8)
#define SWITCHVIEWFRAME CGRectMake(0, self.frame.size.height - CHECKMARKHEIGHT*SCREEN_SCALE, BOOK_WIDTH*SCREEN_SCALE, 30)
#define BADGESIZE   [badgeView badgeSize]
#define BADGEVIEWFRAME CGRectMake(self.frame.size.width - (BADGESIZE.width*SCREEN_SCALE)/2, -(BADGESIZE.height*SCREEN_SCALE)/2, BADGESIZE.width*SCREEN_SCALE*1.1, BADGESIZE.height*SCREEN_SCALE*1.1)
#define SELECTEDIMAGEVIEWFRAME CGRectMake(self.frame.size.width - CHECKMARKWIDTH*SCREEN_SCALE, self.frame.size.height-60-switchView.frame.size.height, CHECKMARKWIDTH*SCREEN_SCALE, CHECKMARKHEIGHT*SCREEN_SCALE)

@implementation BookView
{
    UIButton *backgroundButton;
    CustomProgressView *customprogressView;
    UIImage *selectedImage;
    UIImage *badgeImage;
    UIImageView *selectedImageView;
    MKNumberBadgeView *badgeView;
    UISwitch *switchView;
}
@synthesize delegate;
@synthesize editing;
@synthesize selected;
@synthesize book;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        selectedImage = [UIImage imageNamed:@"local_book_select.png"];
        badgeImage = [UIImage imageNamed:@"badge_bg"];
        
        backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backgroundButton setFrame:BACKGROUNDBUTTONFRAME];
        [backgroundButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backgroundButton];
        
        customprogressView = [[CustomProgressView alloc] init];
        customprogressView.frame = CUSTOMPROGRESSVIEWFRAME;
        [self addSubview:customprogressView];
        
        selectedImageView = [[UIImageView alloc] initWithFrame:SELECTEDIMAGEVIEWFRAME];
        selectedImageView.image = nil;
        [self addSubview:selectedImageView];
        
        badgeView = [[MKNumberBadgeView alloc] init];
        [badgeView setHideWhenZero:YES];
        [badgeView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:badgeView];
        
        switchView = [[UISwitch alloc]initWithFrame:SWITCHVIEWFRAME];
        [switchView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:switchView];
    }
    return self;
}

- (void)valueChanged:(id)sender {
    NSNumber *userid = [BookReaderDefaultManager userid];
    [ServiceManager autoSubscribe:userid book:book.uid andValue:[sender isOn]==YES?@"1":@"0" withBlock:^(NSString *result, NSError *error) {
        if (error) {
            
        }
        else
        {
            NSLog(@"%@",result);
        }
    }];
    if ([sender isOn])
    {
        book.autoBuy = [NSNumber numberWithBool:YES];
    }
    else
    {
        book.autoBuy = [NSNumber numberWithBool:NO];
    }
    if (self.delegate!=nil) {
        [self.delegate switchOnOrOff:sender andBookName:book.name];
    }
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    [backgroundButton setTag:tag];
}


- (void)setEditing:(BOOL)editingOrNot
{
    editing = editingOrNot;
    if (editing)
    {
        [badgeView setHidden:YES];
        [switchView setHidden:NO];
        [backgroundButton setAlpha:0.5];
    }
    else
    {
        [switchView setHidden:YES];
        [badgeView setHidden:NO];
        [backgroundButton setAlpha:1.0];
    }
}

- (void)setSelected:(BOOL)isSelect
{
    selected = isSelect;
    selectedImageView.image = (isSelect) ? selectedImage : nil;
    if (isSelect)
    {
        [backgroundButton setAlpha:1.0];
    }
    else
    {
        [backgroundButton setAlpha:0.5];
    }
}

- (void)buttonClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(bookViewClicked:)]) {
        [self.delegate bookViewClicked:self];
    }
}

- (void)setBook:(Book *)aBook
{
	book = aBook;
    if (book.cover) {
        [backgroundButton setBackgroundImage:[UIImage imageWithData:book.cover] forState:UIControlStateNormal];
    } else {
        [backgroundButton.imageView
         setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:book.coverURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             [self refreshCoverWithImage:image];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
        }];
    }
    if (book.progress) {
        [customprogressView setProgress:book.progress.floatValue];
    }
   
    if (book.autoBuy) {
        [switchView setOn:[book.autoBuy boolValue]];
    }
}

- (void)setBadgeValue:(NSInteger)badgeValue
{
    [badgeView setValue:badgeValue];
    [badgeView setFrame:BADGEVIEWFRAME];
}

- (void)refreshCoverWithImage:(UIImage *)image
{
   book.cover = UIImageJPEGRepresentation(image, 1.0);
   [backgroundButton setBackgroundImage:image forState:UIControlStateNormal];
}

@end
