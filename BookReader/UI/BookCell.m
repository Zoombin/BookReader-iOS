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

#define LabelTextColor    [UIColor colorWithRed:84.0/255.0 green:40.0/255.0 blue:10.0/255.0 alpha:1.0]

@implementation BookCell
{
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *categoryLabel;
	UIImageView *coverView;
}

- (id)initWithStyle:(BookCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (style == BookCellStyleBig) {
            CGRect bookimageViewFrame = CGRectMake(15, 5, 45, 60);
            CGRect bookNameLabelFrame = CGRectMake(75, 8, 205, 15);
            CGRect authorNameLabelFrame = CGRectMake(75, 35, 130, 15);
            CGRect categoryNameLabelFrame = CGRectMake(75, 50, 130, 15);
            
            nameLabel = [[UILabel alloc] initWithFrame:bookNameLabelFrame];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [self.contentView addSubview:nameLabel];
            
            authorLabel = [[UILabel alloc] initWithFrame:authorNameLabelFrame];
            [authorLabel setBackgroundColor:[UIColor clearColor]];
            [authorLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [authorLabel setTextColor:[UIColor blackColor]];
            [self.contentView addSubview:authorLabel];
                        
            categoryLabel = [[UILabel alloc] initWithFrame:categoryNameLabelFrame];
            [categoryLabel setBackgroundColor:[UIColor clearColor]];
            [categoryLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [categoryLabel setTextColor:[UIColor blackColor]];
            [self.contentView addSubview:categoryLabel];
            
            coverView = [[UIImageView alloc] initWithFrame:bookimageViewFrame];
            [self.contentView addSubview:coverView];
            
            UIView *sperateLine = [[UIView alloc] initWithFrame:CGRectMake(10, 69, self.contentView.frame.size.width-30, 0.5)];
            [sperateLine setBackgroundColor:[UIColor blackColor]];
            [self addSubview:sperateLine];
        } else if (style == BookCellStyleSmall){
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 30)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.contentView addSubview:nameLabel];
            
            authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-120, 0, 100, 30)];
            [authorLabel setBackgroundColor:[UIColor clearColor]];
            [authorLabel setTextAlignment:NSTextAlignmentRight];
            [authorLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [authorLabel setTextColor:[UIColor blackColor]];
            [self.contentView addSubview:authorLabel];
            
            UIView *sperateLine = [[UIView alloc] initWithFrame:CGRectMake(10, 29, self.contentView.frame.size.width-30, 0.5)];
            [sperateLine setBackgroundColor:[UIColor blackColor]];
            [self addSubview:sperateLine];
        } else {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 200, 20)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.contentView addSubview:nameLabel];
            
            UIImageView *catagoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-40, 10, 12, 18)];
            [catagoryImage setImage:[UIImage imageNamed:@"catagory_arrow"]];
            [self addSubview:catagoryImage];
            
            UIView *sperateLine = [[UIView alloc] initWithFrame:CGRectMake(10, 39, self.contentView.frame.size.width-30, 0.5)];
            [sperateLine setBackgroundColor:[UIColor blackColor]];
            [self addSubview:sperateLine];
        }
    }
    return self;
}

- (void)setCatagoryName:(NSString *)name
{
    [nameLabel setText:name];
}

- (void)setBook:(Book *)book
{
    if (book.name) {
        [nameLabel setText:[NSString stringWithFormat:@"%@",book.name]];
    }
    if (book.author) {
        [authorLabel setText:[NSString stringWithFormat:@"%@", book.author]];
    }
    if (book.category) {
        categoryLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"CategoryName", nil), book.category];
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

+ (CGFloat)height
{
    return 70.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
