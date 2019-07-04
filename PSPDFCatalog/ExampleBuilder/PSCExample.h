//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCContent.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Allows you to customize the navigation controller to your heart’s content.
typedef void (^PSCExamplePresentationCustomizations)(UINavigationController *container);

@protocol PSCExampleRunnerDelegate <NSObject>

@property (nonatomic, readonly, nullable) UIViewController *currentViewController;

@end

typedef NS_ENUM(NSInteger, PSCExampleCategory) {
    PSCExampleCategoryTop,
    PSCExampleCategoryMultimedia,
    PSCExampleCategoryAnnotations,
    PSCExampleCategoryAnnotationProviders,
    PSCExampleCategoryForms,
    PSCExampleCategoryBarButtons,
    PSCExampleCategoryViewCustomization,
    PSCExampleCategoryStoryboards,
    PSCExampleCategoryTextExtraction,
    PSCExampleCategoryDocumentEditing,
    PSCExampleCategoryDocumentProcessing,
    PSCExampleCategoryDocumentGeneration,
    PSCExampleCategoryControllerCustomization,
    PSCExampleCategoryDocumentDataProvider,
    PSCExampleCategorySecurity,
    PSCExampleCategorySubclassing,
    PSCExampleCategoryTests,
};

extern NSString *PSCHeaderFromExampleCategory(PSCExampleCategory category);
extern NSString *PSCFooterFromExampleCategory(PSCExampleCategory category);

typedef NS_OPTIONS(NSInteger, PSCExampleTargetDeviceMask) {
    PSCExampleTargetDeviceMaskPhone = 1 << 0,
    PSCExampleTargetDeviceMaskPad = 1 << 1,
};

/// Base class for the catalog examples.
@interface PSCExample : NSObject

/// The example title. Mandatory. It is used as an identifier to match Swift and Objective-C examples.
@property (nonatomic, copy) NSString *title;

/// The example description. Optional.
@property (nonatomic, copy, nullable) NSString *contentDescription;

/// Optional type string for shortcuts. Should be in format com.pspdfkit.catalog.<name>.
@property (nonatomic, copy, nullable) NSString *type;

/// The category for this example.
@property (nonatomic) PSCExampleCategory category;

/// Whether the example is written in Swift or not (Objective-C).
@property (nonatomic, readonly) BOOL isSwift;

/**
 * Whether the example written in an another language is present.
 * @note This property is set after the initialization of `allExamples` in `PSCExampleManager`.
 */
@property (nonatomic) BOOL isCounterpartExampleAvailable;

/// Target device. Defaults to `PSCExampleTargetDeviceMaskPhone|PSCExampleTargetDeviceMaskPad`.
@property (nonatomic) PSCExampleTargetDeviceMask targetDevice;

/// The priority of this example.
@property (nonatomic) NSInteger priority;

/// Presents the example modally when set. Defaults to `NO`.
@property (nonatomic) BOOL wantsModalPresentation;

/// Sets up the navigation bar to have a large title. Defaults to `YES`.
@property (nonatomic) BOOL prefersLargeTitles;

/// Will automatically wrap the controller in a `UINavigationController`.
/// Only relevant when `wantsModalPresentation` is set to `YES`. Defaults to `YES`.
@property (nonatomic) BOOL embedModalInNavigationController;

/// Allows you to set all kinds of presentation options and so forth.
@property (nullable, nonatomic, strong) PSCExamplePresentationCustomizations customizations;

/// Builds the sample and returns a new view controller that will then be pushed.
- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate;

@end

/// Concenience category that stores/loads the example via associated objects.
@interface PSCContent (PSCExampleConvenience)

@property (nonatomic, nullable) PSCExample *example;

@end

NS_ASSUME_NONNULL_END
