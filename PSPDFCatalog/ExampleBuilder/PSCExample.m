//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCExample.h"
#import <objc/runtime.h>

// Based on https://stackoverflow.com/a/34054897/88854
// Swift class bits extracted from https://opensource.apple.com/source/objc4/objc4-750/runtime/objc-runtime-new.h
#define FAST_IS_SWIFT (1UL<<0)
#define FAST_IS_SWIFT_STABLE  (1UL<<1)

static uintptr_t getClassBits(Class kls) {
#if __LP64__
    typedef uint32_t mask_t;
#else
    typedef uint16_t mask_t;
#endif

    return ((const struct {
        Class isa;
        Class superclass;
        void *bucket_t;
        mask_t mask;
        mask_t occupied;
        uintptr_t bits;
    } *) (__bridge const void *) kls)->bits;
}

@implementation PSCExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _targetDevice = PSCExampleTargetDeviceMaskPhone | PSCExampleTargetDeviceMaskPad;
        _wantsModalPresentation = NO;
        _embedModalInNavigationController = YES;
        _prefersLargeTitles = YES;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    return nil;
}

- (BOOL)isSwift {
    const uintptr_t bits = getClassBits(self.class);
    return bits & (FAST_IS_SWIFT | FAST_IS_SWIFT_STABLE);
}

@end

NSString *PSCHeaderFromExampleCategory(PSCExampleCategory category) {
    PSC_SWITCH_NOWARN(category) {
        case PSCExampleCategoryMultimedia:
            return @"Multimedia";
        case PSCExampleCategoryAnnotations:
            return @"Annotations";
        case PSCExampleCategoryAnnotationProviders:
            return @"Annotation Providers";
        case PSCExampleCategoryForms:
            return @"Forms and Digital Signatures";
        case PSCExampleCategoryBarButtons:
            return @"Toolbar Customizations";
        case PSCExampleCategoryViewCustomization:
            return @"View Customizations";
        case PSCExampleCategoryStoryboards:
            return @"Storyboards";
        case PSCExampleCategoryTextExtraction:
            return @"Text Extraction / PDF Creation";
        case PSCExampleCategoryDocumentEditing:
            return @"Document Editing";
        case PSCExampleCategoryDocumentProcessing:
            return @"Document Processing";
        case PSCExampleCategoryDocumentGeneration:
            return @"Document Generation";
        case PSCExampleCategoryControllerCustomization:
            return @"ViewController Customization";
        case PSCExampleCategoryDocumentDataProvider:
            return @"Document Data Providers";
        case PSCExampleCategorySecurity:
            return @"Passwords / Security";
        case PSCExampleCategorySubclassing:
            return @"Subclassing";
        case PSCExampleCategoryTests:
            return @"Miscelleaneous Test Cases";
        default:
            return @"";
    }
}

NSString *PSCFooterFromExampleCategory(PSCExampleCategory category) {
    PSC_SWITCH_NOWARN(category) {
        case PSCExampleCategoryMultimedia:
            return @"Integrate videos, audio, images and HTML5 content/websites as part of a document page.";
        case PSCExampleCategoryAnnotations:
            return @"Add, edit or customize different annotations and annotation types.";
        case PSCExampleCategoryAnnotationProviders:
            return @"Examples with different annotation providers.";
        case PSCExampleCategoryForms:
            return @"Interact with or fill forms.";
        case PSCExampleCategoryBarButtons:
            return @"Customize the (annotation) toolbar.";
        case PSCExampleCategoryViewCustomization:
            return @"Various ways to customize the view.";
        case PSCExampleCategoryStoryboards:
            return @"Initialize a PSPDFViewController using storyboards.";
        case PSCExampleCategoryTextExtraction:
            return @"Extract text from document pages and create new document.";
        case PSCExampleCategoryDocumentEditing:
            return @"New page creation, page duplication, reordering, rotation, deletion and exporting.";
        case PSCExampleCategoryDocumentProcessing:
            return @"Various use cases for PSPDFProcessor, like annotation processing and page modifications.";
        case PSCExampleCategoryDocumentGeneration:
            return @"Generate PDF Documents.";
        case PSCExampleCategoryControllerCustomization:
            return @"Multiple ways to customize PSPDFViewController.";
        case PSCExampleCategoryDocumentDataProvider:
            return @"Merge multiple file sources to one logical one using the highly flexible PSPDFDocument.";
        case PSCExampleCategorySecurity:
            return @"Enable encryption and open password protected documents.";
        case PSCExampleCategorySubclassing:
            return @"Various ways to subclass PSPDFKit.";
        default:
            return @"";
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCContent (PSCExampleConvenience)

@implementation PSCContent (PSCExampleConvenience)

static const char PSCExampleStorageKey;

- (nullable PSCExample *)example {
    return objc_getAssociatedObject(self, &PSCExampleStorageKey);
}

- (void)setExample:(nullable PSCExample *)example {
    objc_setAssociatedObject(self, &PSCExampleStorageKey, example, OBJC_ASSOCIATION_RETAIN);
}

@end
