//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

// This is an example how to modify all annotations to render as overlay.
// Note that this is a corner case and isn't as greatly tested.
// Helps in case you want to add custom subviews but still have drawings on top of everything

@interface PSCAnnotationOverlayPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSCDrawAnnotationsAsOverlayExample : PSCExample
@end
@implementation PSCDrawAnnotationsAsOverlayExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Draw all annotations as overlay";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 150;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *controller = [[PSCAnnotationOverlayPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end

@interface PSCOverlayFileAnnotationProvider : PSPDFFileAnnotationProvider
@end

@implementation PSCAnnotationOverlayPDFViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:configuration];
    self.delegate = self;
    self.navigationItem.rightBarButtonItems = @[self.thumbnailsButtonItem, self.annotationButtonItem];

    // register our custom annotation provider as subclass.
    [document overrideClass:PSPDFFileAnnotationProvider.class withClass:PSCOverlayFileAnnotationProvider.class];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didConfigurePageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    // adds a custom view above every page, to demonstrate that the annotations will render ABOVE that view.
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(100.0, 100.0, 300.0, 300.0)];
    customView.backgroundColor = [UIColor colorWithRed:1.0 green:0.846 blue:0.088 alpha:0.9];
    customView.layer.cornerRadius = 10.0;
    customView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.846 blue:0.088 alpha:1.].CGColor;
    customView.layer.borderWidth = 2.0;
    customView.alpha = 0.5;
    [pageView insertSubview:customView belowSubview:pageView.annotationContainerView];
}

@end

@implementation PSCOverlayFileAnnotationProvider

- (NSArray<__kindof PSPDFAnnotation *> *)annotationsForPageAtIndex:(PSPDFPageIndex)pageIndex {
    NSArray<PSPDFAnnotation *> *annotations = [super annotationsForPageAtIndex:pageIndex];

    // make all annotations overlay annotations (they will be rendered in their own views instead of within the page image)
    for (PSPDFAnnotation *annotation in annotations) {
        // Making highlights as overlay really really doesn't look good. (since they are multiplied into the page content, this is not possible with regular UIView composition, so you'd completely overlap the text, unless you make them semi-transparent)
        if ((annotation.type & PSPDFAnnotationTypeTextMarkup) == 0) {
            annotation.overlay = YES;
        }
    }
    return annotations;
}

// Set annotations to render as overlay right after they are inserted.
- (NSArray<__kindof PSPDFAnnotation *> *)addAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations options:(NSDictionary<NSString *, id> *)options {
    for (PSPDFAnnotation *annotation in annotations) {
        if (![annotation isKindOfClass:[PSPDFHighlightAnnotation class]]) {
            annotation.overlay = YES;
        }
    }
    return [super addAnnotations:annotations options:options];
}

@end
