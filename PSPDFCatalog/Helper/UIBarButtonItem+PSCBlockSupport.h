//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (PSCBlockSupport)

/// Simple block-based API for `UIBarButtonItem`.
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style block:(void (^)(id sender))block;

@end

extern void (^psc_targetActionBlock(_Nullable id target, _Nullable SEL action))(_Nullable id);

NS_ASSUME_NONNULL_END
