//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import "PSPDFInkAnnotation+PSCSamples.h"
#import <tgmath.h>

@interface PSCLockedAnnotationsPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSCLockedAnnotationsExample : PSCExample
@end
@implementation PSCLockedAnnotationsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Lock specific annotations";
        self.contentDescription = @"Example how to lock specific annotations. All black annotations cannot be moved anymore.";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 110;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Add some test annotations.
    PSPDFInkAnnotation *ink = [PSPDFInkAnnotation psc_sampleInkAnnotationInRect:CGRectMake(100, 100, 200, 200)];
    ink.color = UIColor.greenColor;
    PSPDFInkAnnotation *ink2 = [PSPDFInkAnnotation psc_sampleInkAnnotationInRect:CGRectMake(300.0, 300.0, 200.0, 200.0)];
    ink2.color = UIColor.blackColor;
    PSPDFInkAnnotation *ink3 = [PSPDFInkAnnotation psc_sampleInkAnnotationInRect:CGRectMake(100.0, 400.0, 200.0, 200.0)];
    ink3.color = UIColor.redColor;
    [document addAnnotations:@[ink, ink2, ink3] options:nil];

    PSPDFViewController *pdfController = [[PSCLockedAnnotationsPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

@implementation PSCLockedAnnotationsPDFViewController

- (void)commonInitWithDocument:(nullable PSPDFDocument *)document configuration:(PSPDFConfiguration *_Nonnull)configuration {
    [super commonInitWithDocument:document configuration:configuration];

    self.delegate = self;

    // Dynamically change selection mode if an annotation changes.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationsChangedNotification:) name:PSPDFAnnotationChangedNotification object:nil];
}

- (void)annotationsChangedNotification:(NSNotification *)notification {
    [self updateAnnotationSelectionView];
}

- (void)updateAnnotationSelectionView {
    // Reevaluate all page views. Usually there's just one but this is more future-proof.
    for (PSPDFPageView *pageView in self.visiblePageViews) {
        BOOL allowEditing = YES;
        for (PSPDFAnnotation *annotation in pageView.selectedAnnotations) {
            // Comparing colors is always tricky - we use a helper and allow some leeway.
            // The helper also deals with details like different color spaces.
            if (PSCIsColorAboutEqualToColorWithTolerance(annotation.color, UIColor.blackColor, 0.1)) {
                allowEditing = NO;
                break;
            }
        }
        pageView.annotationSelectionView.allowEditing = allowEditing;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didSelectAnnotations:(NSArray<PSPDFAnnotation *> *)annotations onPageView:(PSPDFPageView *)pageView {
    // This is called once the annotation selection view has been configured.
    [self updateAnnotationSelectionView];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Helper

static UIColor *PSCColorInRGBColorSpace(UIColor *color) {
    UIColor *newColor = color;

    // convert UIDeviceWhiteColorSpace to UIDeviceRGBColorSpace.
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        CGFloat whiteComponent = components[0];
        newColor = [UIColor colorWithRed:whiteComponent green:whiteComponent blue:whiteComponent alpha:components[1]];
    }

    return newColor;
}

static BOOL PSCIsColorAboutEqualToColorWithTolerance(UIColor *left, UIColor *right, CGFloat tolerance) {
    if (!left || !right) return NO;

    CGColorRef leftColor = PSCColorInRGBColorSpace(left).CGColor;
    CGColorRef rightColor = PSCColorInRGBColorSpace(right).CGColor;

    if (CGColorSpaceGetModel(CGColorGetColorSpace(leftColor)) != CGColorSpaceGetModel(CGColorGetColorSpace(rightColor))) {
        return NO;
    }

    NSInteger componentCount = CGColorGetNumberOfComponents(leftColor);
    const CGFloat *leftComponents = CGColorGetComponents(leftColor);
    const CGFloat *rightComponents = CGColorGetComponents(rightColor);

    for (NSInteger i = 0; i < componentCount; i++) {
        if (fabs(leftComponents[i] - rightComponents[i]) > tolerance) {
            return NO;
        }
    }

    return YES;
}

@end
