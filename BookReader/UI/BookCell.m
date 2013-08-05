//
//  Cell.m
//  BookReader
//
//  Created by ZoomBin on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BookCell.h"
#import "UIImageView+AFNetworking.h"
#import "Book.h"
#import "UIColor+BookReader.h"
#import "NSString+ZBUtilites.h"

#define BigCellHeight 110.0f
#define SmallCellHeight 40.0f
#define OtherCellHeight 40.0f

@implementation BookCell
{
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *shortDescribeLabel;
	UIImageView *coverView;
    UIImageView *finishMark;
	BookCellStyle myStyle;
	CGFloat height;
    UILabel *line;
}

- (id)initWithStyle:(BookCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	myStyle = style;
    self = [super initWithStyle:myStyle reuseIdentifier:reuseIdentifier];
    if (self) {
		CGFloat nameFontSize = 14.0f;
		CGFloat authorFontSize = 12.0f;
		CGFloat categoryFontSize = 12.0f;
		UIColor *authorTextColor = [UIColor bookCellGrayTextColor];
		UIColor *shortDescribeTextColor = [UIColor bookCellGrayTextColor];
	
		CGRect coverRect = CGRectZero;
		CGRect nameRect = CGRectZero;
		CGRect authorRect = CGRectZero;
		CGRect describeRect = CGRectZero;
        CGRect finishRect = CGRectZero;

		NSTextAlignment authorAlignment = NSTextAlignmentLeft;
		
        if (style == BookCellStyleBig) {
			height = BigCellHeight;
            coverRect = CGRectMake(15, 12, BOOK_COVER_ORIGIN_SIZE.width / 1.8, BOOK_COVER_ORIGIN_SIZE.height / 1.8);
            nameRect = CGRectMake(CGRectGetMaxX(coverRect) + 10, 10, 205, 15);
            authorRect = CGRectMake(CGRectGetMinX(nameRect), CGRectGetMaxY(nameRect) + 7, 130, 15);
            describeRect = CGRectMake(CGRectGetMinX(nameRect), CGRectGetMaxY(authorRect) + 3, 215, 30);
            finishRect = CGRectMake(CGRectGetMaxX(nameRect) + 5, 12, 15, 15);
        } else if (myStyle == BookCellStyleSmall){
			height = SmallCellHeight;
			nameRect = CGRectMake(15, 5, 200, 30);
			nameFontSize = 16.0f;
            
			authorRect = CGRectMake(self.bounds.size.width - 130, 5, 100, 30);
            authorTextColor = [UIColor blackColor];
			authorAlignment = NSTextAlignmentRight;
		} else {//目录界面
			height = OtherCellHeight;
			nameRect = CGRectMake(25, 12, 250, 20);
			nameFontSize = 18.0f;
        }
		
		if (!CGRectEqualToRect(nameRect, CGRectZero)) {
			nameLabel = [[UILabel alloc] initWithFrame:nameRect];
			nameLabel.backgroundColor = [UIColor clearColor];
			nameLabel.font = [UIFont boldSystemFontOfSize:nameFontSize];
			nameLabel.textColor = [UIColor blackColor];
			[self.contentView addSubview:nameLabel];
		}
		
		if (!CGRectEqualToRect(authorRect, CGRectZero)) {
			authorLabel = [[UILabel alloc] initWithFrame:authorRect];
			authorLabel.backgroundColor = [UIColor clearColor];
            if (myStyle == BookCellStyleSmall) {
                [authorLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            }
			authorLabel.font = [UIFont boldSystemFontOfSize:authorFontSize];
			authorLabel.textColor = authorTextColor;
			authorLabel.textAlignment = authorAlignment;
			[self.contentView addSubview:authorLabel];
		}
		
		if (!CGRectEqualToRect(describeRect, CGRectZero)) {
			shortDescribeLabel = [[UILabel alloc] initWithFrame:describeRect];
            [shortDescribeLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
			shortDescribeLabel.backgroundColor = [UIColor clearColor];
            shortDescribeLabel.lineBreakMode = UILineBreakModeWordWrap;
            shortDescribeLabel.numberOfLines = 0;
			shortDescribeLabel.font = [UIFont boldSystemFontOfSize:categoryFontSize];
			shortDescribeLabel.textColor = shortDescribeTextColor;
			[self.contentView addSubview:shortDescribeLabel];
		}
        
        if (!CGRectEqualToRect(finishRect, CGRectZero)) {
            finishMark = [[UIImageView alloc] initWithFrame:finishRect];
            [finishMark setImage:[UIImage imageNamed:@"finish_mark"]];
            [self.contentView addSubview:finishMark];
        }
		
		if (!CGRectEqualToRect(coverRect, CGRectZero)) {
            coverView = [[UIImageView alloc] initWithFrame:coverRect];
			[self.contentView addSubview:coverView];
		}
		
        line = [UILabel dashLineWithFrame:CGRectMake(0, height - 2, self.contentView.frame.size.width + 20, 2)];
        [self.contentView addSubview:line];
    }
    return self;
}

- (void)hidenDottedLine
{
    [line setHidden:YES];
}

- (void)setTextLableText:(NSString *)name
{
    [nameLabel setText:name];
}

- (void)setBook:(Book *)book
{
    if (book.name) {
        [nameLabel setText:[NSString stringWithFormat:@"%@",book.name]];
        if (myStyle == BookCellStyleBig) {
            [nameLabel sizeToFit];
            [finishMark setFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 5, 12, 15, 15)];
            [finishMark setHidden:book.status.integerValue == 0 ? YES : NO];
        }
    }
    if (book.author) {
		NSString *displayAuthorString = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"AuthorName", nil),book.author];
        if (myStyle == BookCellStyleSmall) {
            displayAuthorString = book.author;
        }
		authorLabel.text = displayAuthorString;
    } else {
        [shortDescribeLabel setFrame:CGRectMake(15 + BOOK_COVER_ORIGIN_SIZE.width / 1.8 + 10, 35, 200, 30)];
    }
    if (book.describe) {
        shortDescribeLabel.text = [NSString stringWithFormat:@"简介 : %@", [[book.describe substringToIndex:book.describe.length >= 28 ? 28 : [book.describe length]] stringByAppendingString:@"..."]];
    }
    if (book.cover) {
        coverView.image = [UIImage imageWithData:book.cover];
    } else if (book.coverURL) {
		coverView.image = [UIImage imageNamed:@"book_placeholder"];
		UIImageView *imageView = [[UIImageView alloc] init];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:book.coverURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			coverView.image = image;
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		   
		}];
    }
}

- (CGFloat)height
{
	return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
