//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PSCDeallocationBlock)

// Register block to be called when `self` is deallocated.
- (void)psc_addDeallocBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
