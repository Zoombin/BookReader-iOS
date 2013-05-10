//
//  Cell.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookCell.h"
#import "BookReader.h"
#import "UIImageView+AFNetworking.h"
#import "Book.h"

#define bookimageViewFrame      CGRectMake(15, 10, 90, 120)
#define bookNameLabelFrame      CGRectMake(115, 20, 205, 30)
#define authorNameLabelFrame    CGRectMake(115, 55, 130, 30)
#define categoryNameLabelFrame  CGRectMake(115, 90, 130, 30)
#define locationNameLabelFrame  CGRectMake(MAIN_SCREEN.size.width-100, 42, 110, 30)
#define LabelTextColor          [UIColor colorWithRed:84.0/255.0 green:40.0/255.0 blue:10.0/255.0 alpha:1.0]

@implementation BookCell
{
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *progressLabel;
    UILabel *categoryLabel;
    UIImageView *coverView;
}

- (id)initWithStyle:(BookCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (style == BookCellStyleBig) {
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(5, 1, self.bounds.size.width-20, 140-2)];
            [background setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
            [self.contentView addSubview:background];
            
            nameLabel = [[UILabel alloc] initWithFrame:bookNameLabelFrame];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.contentView addSubview:nameLabel];
            
            authorLabel = [[UILabel alloc] initWithFrame:authorNameLabelFrame];
            [authorLabel setBackgroundColor:[UIColor clearColor]];
            [authorLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [authorLabel setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:authorLabel];
            
            progressLabel = [[UILabel alloc] initWithFrame:locationNameLabelFrame];
            [progressLabel setBackgroundColor:[UIColor clearColor]];
            [progressLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [progressLabel setTextColor:LabelTextColor];
            [self.contentView addSubview:progressLabel];
            
            categoryLabel = [[UILabel alloc] initWithFrame:categoryNameLabelFrame];
            [categoryLabel setBackgroundColor:[UIColor clearColor]];
            [categoryLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [categoryLabel setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:categoryLabel];
            
            coverView = [[UIImageView alloc] initWithFrame:bookimageViewFrame];
            [self.contentView addSubview:coverView];
        } else {
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(5, 1, self.bounds.size.width-20, 30-2)];
            [background setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
            [self.contentView addSubview:background];
            
            
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 30)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextColor:[UIColor blackColor]];
            [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [self.contentView addSubview:nameLabel];
            
            authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-120, 0, 100, 30)];
            [authorLabel setBackgroundColor:[UIColor clearColor]];
            [authorLabel setTextAlignment:NSTextAlignmentRight];
            [authorLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [authorLabel setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:authorLabel];

        }
    }
    return self;
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
        [coverView setImageWithURL:[NSURL URLWithString:book.coverURL]];
    }
}

+ (CGFloat)height
{
    return 140.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
