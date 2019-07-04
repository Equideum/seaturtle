//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCViewHelper.h"
#import <mach-o/dyld.h>
#import <tgmath.h>

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Animations

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN CGFloat UIAnimationDragCoefficient(void); // UIKit private drag coeffient.
#endif

static CGFloat PSCSimulatorAnimationDragCoefficient(void) {
#if TARGET_IPHONE_SIMULATOR
    return UIAnimationDragCoefficient();
#else
    return 1.0;
#endif
}

CATransition *PSCFadeTransitionWithDuration(CGFloat duration) {
    CATransition *transition = [CATransition animation];
    transition.duration = duration * PSCSimulatorAnimationDragCoefficient();
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    return transition;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Introspection

UIView *_Nullable PSCGetViewInsideView(UIView *view, NSString *classNamePrefix) {
    if (!view || classNamePrefix.length == 0) return nil;

    UIView *theView;
    for (UIView *subview in view.subviews) {
        if ([NSStringFromClass(subview.class) hasPrefix:classNamePrefix] || [NSStringFromClass(subview.superclass) hasPrefix:classNamePrefix]) {
            return subview;
        } else {
            if ((theView = PSCGetViewInsideView(subview, classNamePrefix))) break;
        }
    }
    return theView;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Geometry

CGFloat PSCScaleForSizeWithinSize(CGSize targetSize, CGSize boundsSize) {
    CGFloat xScale = boundsSize.width / targetSize.width;
    CGFloat yScale = boundsSize.height / targetSize.height;
    CGFloat minScale = __tg_fmin(xScale, yScale);
    return minScale > 1. ? 1.0 : minScale;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Popover

BOOL PSCIsControllerClassAndVisible(id c, Class controllerClass) { return [c isKindOfClass:controllerClass] || ([c isKindOfClass:UINavigationController.class] && [((UINavigationController *)c).visibleViewController isKindOfClass:controllerClass]); }
