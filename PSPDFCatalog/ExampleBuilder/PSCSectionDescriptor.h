//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

NS_ASSUME_NONNULL_BEGIN

@class PSCContent;

/// Simple model class to describe static section.
@interface PSCSectionDescriptor : NSObject

+ (instancetype)sectionWithTitle:(nullable NSString *)title footer:(nullable NSString *)footer;
- (void)addContent:(PSCContent *)contentDescriptor;

@property (nonatomic, copy) NSArray<PSCContent *> *contentDescriptors;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *footer;
@property (nonatomic, nullable) UIView *headerView;
@property (nonatomic) BOOL isCollapsed;

@end

NS_ASSUME_NONNULL_END
