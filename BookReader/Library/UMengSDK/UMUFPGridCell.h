//
//  UMUFPGridCell.h
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IndexPath;

@interface UMUFPGridCell : UIView
{
    int _columnCount; 
    IndexPath *_indexPath; 
    NSString  *_strReuseIndentifier; 
}

@property (nonatomic) int     columnCount; 
@property (nonatomic, retain) IndexPath *indexPath;
@property (nonatomic, retain) NSString  *strReuseIndentifier;

- (id)initWithIdentifier:(NSString *)indentifier;
- (void)relayoutViews;

@end

@interface IndexPath : NSObject
{
    int _row;       
    int _column;   
}

@property(nonatomic) int row;
@property(nonatomic) int column;

+ (IndexPath *)initWithRow:(int)indexRow withColumn:(int)indexColumn;

@end