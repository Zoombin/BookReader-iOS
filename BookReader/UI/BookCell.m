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

#define LabelTextColor    [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:117.0/255.0 alpha:1.0]

#define BigCellHeight 90.0f
#define SmallCellHeight 30.0f
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
}

- (id)initWithStyle:(BookCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	myStyle = style;
    self = [super initWithStyle:myStyle reuseIdentifier:reuseIdentifier];
    if (self) {
        if (style == BookCellStyleBig) {
			height = BigCellHeight;
            CGRect bookimageViewFrame = CGRectMake(15, 12, 90/1.8, 115/1.8);
            CGRect bookNameLabelFrame = CGRectMake(75, 15, 205, 15);
            CGRect authorNameLabelFrame = CGRectMake(75, 35, 130, 15);
            CGRect categoryNameLabelFrame = CGRectMake(75, 55, 130, 15);
            
            nameLabel = [[UILabel alloc] initWithFrame:bookNameLabelFrame];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [self.contentView addSubview:nameLabel];
            
            authorLabel = [[UILabel alloc] initWithFrame:authorNameLabelFrame];
            [authorLabel setBackgroundColor:[UIColor clearColor]];
            [authorLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [authorLabel setTextColor:LabelTextColor];
            [self.contentView addSubview:authorLabel];
                        
            categoryLabel = [[UILabel alloc] initWithFrame:categoryNameLabelFrame];
            [categoryLabel setBackgroundColor:[UIColor clearColor]];
            [categoryLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [categoryLabel setTextColor:LabelTextColor];
            [self.contentView addSubview:categoryLabel];
            
            coverView = [[UIImageView alloc] initWithFrame:bookimageViewFrame];
            [self.contentView addSubview:coverView];
        } else if (myStyle == BookCellStyleSmall){
			height = SmallCellHeight;
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 30)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.contentView addSubview:nameLabel];
            
            authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-142, 0, 100, 30)];
            [authorLabel setBackgroundColor:[UIColor clearColor]];
            [authorLabel setTextAlignment:UITextAlignmentRight];
            [authorLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [authorLabel setTextColor:[UIColor blackColor]];
            [self.contentView addSubview:authorLabel];
		} else {//分类界面
			height = OtherCellHeight;
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 12, 200, 20)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [self.contentView addSubview:nameLabel];
            
             catagoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-30, 14, 6, 12)];
            [catagoryImage setImage:[UIImage imageNamed:@"catagory_arrow"]];
            [self.contentView addSubview:catagoryImage];
        }
		separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, height-1, self.contentView.frame.size.width - 10, 1)];
		[separateLine setBackgroundColor:[UIColor lightGrayColor]];
		[self.contentView addSubview:separateLine];
    }
    return self;
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
