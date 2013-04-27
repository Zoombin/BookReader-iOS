//
//  Cell.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookCell.h"
#import "UIDefines.h"
#import "UIImageView+AFNetworking.h"
#import "Book.h"

#define bookimageViewFrame      CGRectMake(10, 16, 52, 70)
#define bookNameLabelFrame      CGRectMake(65, 12, 240, 30)
#define authorNameLabelFrame    CGRectMake(65, 42, 135, 30)
#define categoryNameLabelFrame  CGRectMake(65, 72, 135, 30)
#define locationNameLabelFrame  CGRectMake(MAIN_SCREEN.size.width-100, 42, 110, 30)
#define LabelTextColor          [UIColor colorWithRed:100.0/255.0 green:50.0/255.0 blue:11.0/255.0 alpha:1.0]

@implementation BookCell
{
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *progressLabel;
    UILabel *categoryLabel;
    UIImageView *coverView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *cellBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_cellbackground.png"]];
        [self setBackgroundView:cellBackground];
        
        nameLabel = [[UILabel alloc] initWithFrame:bookNameLabelFrame];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:LabelTextColor];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [self.contentView addSubview:nameLabel];
        
        authorLabel = [[UILabel alloc] initWithFrame:authorNameLabelFrame];
        [authorLabel setBackgroundColor:[UIColor clearColor]];
        [authorLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [authorLabel setTextColor:LabelTextColor];
        [self.contentView addSubview:authorLabel];
        
        progressLabel = [[UILabel alloc] initWithFrame:locationNameLabelFrame];
        [progressLabel setBackgroundColor:[UIColor clearColor]];
        [progressLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [progressLabel setTextColor:LabelTextColor];
        [self.contentView addSubview:progressLabel];
        
        categoryLabel = [[UILabel alloc] initWithFrame:categoryNameLabelFrame];
        [categoryLabel setBackgroundColor:[UIColor clearColor]];
        [categoryLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [categoryLabel setTextColor:LabelTextColor];
        [self.contentView addSubview:categoryLabel];

        coverView = [[UIImageView alloc] initWithFrame:bookimageViewFrame];
        [self.contentView addSubview:coverView];        
    }
    return self;
}

- (void)setBook:(id<BookInterface>)book
{
    if (book.name) {
        [nameLabel setText:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"BookName", nil), book.name]];
    }
    if (book.author) {
        [authorLabel setText:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"AuthorName", nil), book.author]];
    }
//    if (book.progress) {
//        progressLabel.text = [NSString stringWithFormat:@"%@:%.1f", NSLocalizedString(@"ReadPosition", nil), book.progress.floatValue];
//    }
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
    return 100.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
