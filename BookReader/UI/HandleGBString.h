
#import <Foundation/Foundation.h>

@interface HandleGBString : NSObject
+ (NSMutableString *)handleGBString:(NSString *)origin withFontSize:(int)fontSize andPages:(NSMutableArray **)pages andGBCode:(BOOL)bGB andAD:(BOOL)bAD;
@end
