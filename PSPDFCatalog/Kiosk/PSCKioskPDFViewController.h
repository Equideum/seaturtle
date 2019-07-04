//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <PSPDFKitUI/PSPDFKitUI.h>

@class PSCMagazine;

NS_ASSUME_NONNULL_BEGIN

/// Customized subclass of PSPDFViewController, adding more user interface buttons.
@interface PSCKioskPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>

/// Referenced magazine; just a cast to .document.
@property (nonatomic, readonly, nullable) PSCMagazine *magazine;

@end

NS_ASSUME_NONNULL_END
