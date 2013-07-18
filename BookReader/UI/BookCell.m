//
//  Cell.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookCell.h"
#import "UIImageView+AFNetworking.h"
#import "Book.h"
#import "BookReader.h"
#import "UIColor+BookReader.h"

#define BigCellHeight 110.0f
#define SmallCellHeight 40.0f
#define OtherCellHeight 40.0f

@implementation BookCell
{
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *shortDescribeLabel;
	UIImageView *coverView;
	BookCellStyle myStyle;
    UIImageView *catagoryImage;
	CGFloat height;
    UILabel *dottedLine;
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

		NSTextAlignment authorAlignment = NSTextAlignmentLeft;
		
        if (style == BookCellStyleBig) {
			height = BigCellHeight;
            coverRect = CGRectMake(15, 12, BOOK_COVER_ORIGIN_SIZE.width / 1.8, BOOK_COVER_ORIGIN_SIZE.height / 1.8);
            nameRect = CGRectMake(CGRectGetMaxX(coverRect) + 10, 15, 205, 15);
            authorRect = CGRectMake(CGRectGetMinX(nameRect), CGRectGetMaxY(nameRect) + 5, 130, 15);
            describeRect = CGRectMake(CGRectGetMinX(nameRect), CGRectGetMaxY(authorRect) + 5, 200, 30);
            

        } else if (myStyle == BookCellStyleSmall){
			height = SmallCellHeight;
			nameRect = CGRectMake(15, 5, 200, 30);
			nameFontSize = 16.0f;
            
			authorRect = CGRectMake(self.bounds.size.width - 142, 5, 100, 30);
            authorTextColor = [UIColor blackColor];
			authorAlignment = NSTextAlignmentRight;
		} else {//目录界面
			height = OtherCellHeight;
			nameRect = CGRectMake(25, 12, 250, 20);
			nameFontSize = 18.0f;

             catagoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 50, 14, 6, 12)];
            [catagoryImage setImage:[UIImage imageNamed:@"catagory_arrow"]];
            [self.contentView addSubview:catagoryImage];
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
			authorLabel.font = [UIFont boldSystemFontOfSize:authorFontSize];
			authorLabel.textColor = authorTextColor;
			authorLabel.textAlignment = authorAlignment;
			[self.contentView addSubview:authorLabel];
		}
		
		if (!CGRectEqualToRect(describeRect, CGRectZero)) {
			shortDescribeLabel = [[UILabel alloc] initWithFrame:describeRect];
			shortDescribeLabel.backgroundColor = [UIColor clearColor];
            shortDescribeLabel.lineBreakMode = UILineBreakModeWordWrap;
            shortDescribeLabel.numberOfLines = 0;
			shortDescribeLabel.font = [UIFont boldSystemFontOfSize:categoryFontSize];
			shortDescribeLabel.textColor = shortDescribeTextColor;
			[self.contentView addSubview:shortDescribeLabel];
		}
		
		if (!CGRectEqualToRect(coverRect, CGRectZero)) {
            coverView = [[UIImageView alloc] initWithFrame:coverRect];
			[self.contentView addSubview:coverView];
		}
		
        dottedLine = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 2, self.contentView.frame.size.width + 10, 2)];
        [dottedLine setText:@"-----------------------------------------------"];
        [dottedLine setBackgroundColor:[UIColor clearColor]];
        [dottedLine setTextColor:[UIColor grayColor]];
        [self.contentView addSubview:dottedLine];
    }
    return self;
}

- (void)hidenDottedLine
{
    [dottedLine setHidden:YES];
}

- (void)setTextLableText:(NSString *)name
{
    [nameLabel setText:name];
}

- (void)hidenArrow:(BOOL)hiden
{
    if (catagoryImage) {
        [catagoryImage setHidden:hiden];
    }
}

- (void)setBook:(Book *)book
{
    if (book.name) {
        [nameLabel setText:[NSString stringWithFormat:@"%@",book.name]];
    }
    if (book.author) {
        [authorLabel setText:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"AuthorName", nil),book.author]];
        if (myStyle == BookCellStyleSmall) {
            authorLabel.text = book.author;
        }
    } else {
        [shortDescribeLabel setFrame:CGRectMake(15 + BOOK_COVER_ORIGIN_SIZE.width / 1.8 + 10, 35, 200, 30)];
    }
    if (book.describe) {
        shortDescribeLabel.text = [NSString stringWithFormat:@"%@ : %@",@"简介", [[book.describe substringToIndex:[book.describe length] >=28 ? 28 : [book.describe length]] stringByAppendingString:@"..."]];
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
