//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Simple model class to describe static content.
@interface PSCContent : NSObject

+ (instancetype)contentWithTitle:(nullable NSString *)title description:(nullable NSString *)description;
+ (instancetype)sectionHeaderContentWithTitle:(nullable NSString *)title description:(nullable NSString *)description;

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *contentDescription;
@property (nonatomic, readonly) BOOL isSectionHeader;

@end

NS_ASSUME_NONNULL_END
