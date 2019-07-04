//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Animations

FOUNDATION_EXTERN CATransition *PSCFadeTransitionWithDuration(CGFloat duration);

#pragma mark - View Introspection

FOUNDATION_EXTERN UIView *_Nullable PSCGetViewInsideView(UIView *view, NSString *classNamePrefix);

#pragma mark - Geometry

FOUNDATION_EXTERN CGFloat PSCScaleForSizeWithinSize(CGSize targetSize, CGSize boundsSize);

/// Detect if a popover of class `controllerClass` is visible.
FOUNDATION_EXTERN BOOL PSCIsControllerClassAndVisible(_Nullable id c, Class controllerClass);

NS_ASSUME_NONNULL_END
