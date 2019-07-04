//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "UINavigationItem+PSCFiltering.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UINavigationItem (PSCFiltering)

+ (NSArray<UIBarButtonItem *> *)psc_filteredItems:(NSArray<UIBarButtonItem *> *)items forNavigationBar:(nullable UINavigationBar *)navigationBar {
    if (!navigationBar) {
        return items;
    }
    const CGFloat availableSpace = CGRectGetWidth(navigationBar.bounds) * 0.5f;
    NSMutableArray<UIBarButtonItem *> *filtered = [NSMutableArray new];
    CGFloat totalWidth = 0;
    for (NSUInteger idx = 0; idx < items.count; ++idx) {
        UIBarButtonItem *item = items[idx];
        totalWidth += item.customView ? CGRectGetWidth(item.customView.frame) : 50.f;
        if (totalWidth <= availableSpace) {
            [filtered addObject:item];
        }
    }
    return [filtered copy];
}

@end

NS_ASSUME_NONNULL_END
