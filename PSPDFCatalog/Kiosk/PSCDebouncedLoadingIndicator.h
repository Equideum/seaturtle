//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@interface PSCDebouncedLoadingIndicator : UIView

/**
 The time to wait before the view becomes visible after adding it to the view hierarchy.

 Defaults to 0.2
 */
@property (nonatomic) NSTimeInterval gracePeriod;

@end
