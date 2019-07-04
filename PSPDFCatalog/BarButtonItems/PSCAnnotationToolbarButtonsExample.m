//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

// Custom annotation toolbar subclass that adds a "Clear" button that removes all visible annotations.
@interface PSCCustomButtonAnnotationToolbar : PSPDFAnnotationToolbar
@property (nonatomic) PSPDFToolbarButton *clearAnnotationsButton;
@end

@interface PSCCustomButtonAnnotationToolbarButtonsExample : PSCExample
@end
@implementation PSCCustomButtonAnnotationToolbarButtonsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add a custom button to the annotation toolbar";
        self.contentDescription = @"Will add a 'Clear' button to the annotation toolbar that removes all annotations from the visible page.";
        self.category = PSCExampleCategoryBarButtons;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFAnnotationToolbar.class withClass:PSCCustomButtonAnnotationToolbar.class];
    }]];
    return pdfController;
}

@end

@implementation PSCCustomButtonAnnotationToolbar

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
        // The biggest challenge here isn't the clear button, but correctly updating the clear button if we actually can clear something or not.
        NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
        [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationChangedNotification object:nil];
        [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsAddedNotification object:nil];
        [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsRemovedNotification object:nil];

        // We could also use the delegate, but this is cleaner.
        [dnc addObserver:self selector:@selector(willShowSpreadViewNotification:) name:PSPDFDocumentViewControllerWillBeginDisplayingSpreadViewNotification object:nil];

        // Add clear button
        UIImage *clearImage = [[PSPDFKit imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _clearAnnotationsButton = [PSPDFToolbarButton new];
        _clearAnnotationsButton.accessibilityLabel = @"Clear";
        [_clearAnnotationsButton setImage:clearImage];
        [_clearAnnotationsButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self updateClearAnnotationButton];
        self.additionalButtons = @[_clearAnnotationsButton];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Clear Button Action

- (void)clearButtonPressed:(id)sender {
    // Iterate over all visible pages and remove all but links and widgets (forms).
    PSPDFViewController *pdfController = self.annotationStateManager.pdfController;
    PSPDFDocument *document = pdfController.document;
    for (PSPDFPageView *pageView in pdfController.visiblePageViews) {
        NSArray<PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:pageView.pageIndex type:PSPDFAnnotationTypeAll & ~(PSPDFAnnotationTypeLink | PSPDFAnnotationTypeWidget)];
        [document removeAnnotations:annotations options:nil];

        // Remove any annotation on the page as well (updates views)
        // Alternatively, you can call `reloadData` on the pdfController as well.
        for (PSPDFAnnotation *annotation in annotations) {
            [pageView removeAnnotation:annotation options:nil animated:YES];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications

// If we detect annotation changes, schedule a reload.
- (void)annotationChangedNotification:(NSNotification *)notification {
    // Re-evaluate toolbar button
    if (self.window) {
        [self updateClearAnnotationButton];
    }
}

- (void)willShowSpreadViewNotification:(NSNotification *)notification {
    [self updateClearAnnotationButton];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFAnnotationStateManagerDelegate

- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeUndoState:(BOOL)undoEnabled redoState:(BOOL)redoEnabled {
    [super annotationStateManager:manager didChangeUndoState:undoEnabled redoState:redoEnabled];
    [self updateClearAnnotationButton];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)updateClearAnnotationButton {
    __block BOOL annotationsFound = NO;
    PSPDFViewController *pdfController = self.annotationStateManager.pdfController;
    [pdfController.visiblePageIndexes enumerateIndexesUsingBlock:^(NSUInteger pageIndex, BOOL *stop) {
        NSArray<PSPDFAnnotation *> *annotations = [pdfController.document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeAll & ~(PSPDFAnnotationTypeLink | PSPDFAnnotationTypeWidget)];
        if (annotations.count > 0) {
            annotationsFound = YES;
            *stop = YES;
        }
    }];
    self.clearAnnotationsButton.enabled = annotationsFound;
}

@end
