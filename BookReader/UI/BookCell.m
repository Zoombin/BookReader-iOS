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

#define LabelTextColor    [UIColor colorWithRed:162.0/255.0 green:160.0/255.0 blue:147.0/255.0 alpha:1.0]

#define BigCellHeight 90.0f
#define SmallCellHeight 40.0f
#define OtherCellHeight 40.0f

@implementation BookCell
{
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *categoryLabel;
	UIImageView *coverView;
	BookCellStyle myStyle;
    UIImageView *catagoryImage;
	CGFloat height;
    UIView *separateLine;
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
		UIColor *authorTextColor = LabelTextColor;
		UIColor *categoryTextColor = LabelTextColor;
	
		CGRect coverRect = CGRectZero;
		CGRect nameRect = CGRectZero;
		CGRect authorRect = CGRectZero;
		CGRect categoryRect = CGRectZero;

		NSTextAlignment authorAlignment = NSTextAlignmentLeft;
		
        if (style == BookCellStyleBig) {
			height = BigCellHeight;
            coverRect = CGRectMake(15, 12, 90/1.8, 115/1.8);
            nameRect = CGRectMake(75, 15, 205, 15);
            authorRect = CGRectMake(75, 35, 130, 15);
            categoryRect = CGRectMake(75, 55, 130, 15);

        } else if (myStyle == BookCellStyleSmall){
			height = SmallCellHeight;
			nameRect = CGRectMake(15, 5, 200, 30);
			nameFontSize = 16.0f;
            
			authorRect = CGRectMake(self.bounds.size.width - 142, 5, 100, 30);
			authorAlignment = NSTextAlignmentRight;
		} else {//目录界面
			height = OtherCellHeight;
			nameRect = CGRectMake(25, 12, 250, 20);
			nameFontSize = 18.0f;

             catagoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 50, 14, 6, 12)];
            [catagoryImage setImage:[UIImage imageNamed:@"catagory_arrow"]];
            [self.contentView addSubview:catagoryImage];
        }
		
		if (CGRectEqualToRect(nameRect, CGRectZero)) {
			nameLabel = [[UILabel alloc] initWithFrame:nameRect];
			nameLabel.backgroundColor = [UIColor clearColor];
			nameLabel.font = [UIFont boldSystemFontOfSize:nameFontSize];
			nameLabel.textColor = [UIColor blackColor];
			[self.contentView addSubview:nameLabel];
		}
		
		if (CGRectEqualToRect(authorRect, CGRectZero)) {
			authorLabel = [[UILabel alloc] initWithFrame:authorRect];
			authorLabel.backgroundColor = [UIColor clearColor];
			authorLabel.font = [UIFont boldSystemFontOfSize:authorFontSize];
			authorLabel.textColor = authorTextColor;
			authorLabel.textAlignment = authorAlignment;
			[self.contentView addSubview:authorLabel];
		}
		
		if (CGRectEqualToRect(categoryRect, categoryRect)) {
			categoryLabel = [[UILabel alloc] initWithFrame:categoryRect];
			categoryLabel.backgroundColor = [UIColor clearColor];
			categoryLabel.font = [UIFont boldSystemFontOfSize:categoryFontSize];
			categoryLabel.textColor = categoryTextColor;
			[self.contentView addSubview:categoryLabel];
		}
		
		if (coverView) {
			[self.contentView addSubview:coverView];
		}
		
		separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, height - 1, self.contentView.frame.size.width - 10, 1)];
		[separateLine setBackgroundColor:[UIColor lightGrayColor]];
		[self.contentView addSubview:separateLine];
        
        dottedLine = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 1, self.contentView.frame.size.width + 10, 2)];
        [dottedLine setText:@"-----------------------------------------------"];
        [dottedLine setBackgroundColor:[UIColor clearColor]];
        [dottedLine setTextColor:[UIColor grayColor]];
        [self.contentView addSubview:dottedLine];
        [dottedLine setHidden:YES];
    }
    return self;
}

- (void)showDottedLine
{
    [separateLine setHidden:YES];
    [dottedLine setHidden:NO];
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

- (void)separateLineColor:(UIColor *)color
{
    [separateLine setBackgroundColor:color];
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
    }
    if (book.category) {
        categoryLabel.text = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"CategoryName", nil), book.category];
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
