//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationItem (PSCFiltering)

/**
 We will limit the items in the navigation bar as iOS does not do that for us and
 starts overlapping right and left items. To prevent that we calculate the max
 number of items so that we should never cover more than half of the navigation
 bar with our items.

 We're taking the width for `customView` items and assuming all remaining items have a width of ~50pt.
 This works out pretty well with our standard icons, but it is just an approximation.
 */
+ (NSArray<UIBarButtonItem *> *)psc_filteredItems:(NSArray<UIBarButtonItem *> *)items forNavigationBar:(nullable UINavigationBar *)navigationBar;

@end

NS_ASSUME_NONNULL_END
