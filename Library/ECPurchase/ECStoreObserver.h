//
//  ECStoreObserver.h
//  myPurchase
//
//  Created by ris on 10-4-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#ifndef RELEASE_SAFELY(__POINTER)
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#endif

/******************************
 ECStoreObserver
 ******************************/
@interface ECStoreObserver : NSObject <SKPaymentTransactionObserver>
{
	NSMutableArray	*_completeTrans;
	NSMutableArray	*_failedTrans;
	NSMutableArray	*_restoreTrans;
}
@property(nonatomic, strong)NSMutableArray *completeTrans;
@property(nonatomic, strong)NSMutableArray *failedTrans;
@property(nonatomic, strong)NSMutableArray *restoreTrans;

- (void)recordTransaction:(SKPaymentTransaction *)transaction withStatus:(int)status;
- (void)provideContent:(NSString *)productIdentifier;

- (void)completeTransaction: (SKPaymentTransaction *)transaction;
- (void)failedTransaction: (SKPaymentTransaction *)transaction;
- (void)restoreTransaction: (SKPaymentTransaction *)transaction;

@end
