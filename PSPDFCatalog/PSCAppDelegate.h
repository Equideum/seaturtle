//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Availability.h>

#if !defined(__IPHONE_12_2)
#warning PSPDFKit 8 has been designed for Xcode 10.2 with SDK 12. Other combinations are not supported.
#endif

@interface PSCAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, nonnull) UINavigationController *catalogStack;
@property (nonatomic, nonnull) UIWindow *window;

@end
