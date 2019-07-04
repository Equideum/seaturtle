//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCShowHighlightNotesPDFController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSCShowNoteControllerForHighlightsExample : PSCExample
@end
@implementation PSCShowNoteControllerForHighlightsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Directly show note controller for highlight annotations";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 160;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];

    // Create some highlights
    const NSUInteger pageIndex = 5;
    PSPDFTextParser *textParser = [document textParserForPageAtIndex:pageIndex];
    for (NSUInteger idx = 0; idx < 6; idx++) {
        PSPDFWord *word = textParser.words[idx];
        PSPDFHighlightAnnotation *annotation = [PSPDFHighlightAnnotation new];
        CGRect boundingBox;
        annotation.rects = PSPDFRectsFromGlyphs([textParser.glyphs subarrayWithRange:word.range], &boundingBox);
        annotation.boundingBox = boundingBox;
        annotation.pageIndex = pageIndex;
        [document addAnnotations:@[annotation] options:nil];
    }

    PSPDFViewController *controller = [[PSCShowHighlightNotesPDFController alloc] initWithDocument:document];
    controller.pageIndex = pageIndex;
    return controller;
}

@end

@implementation PSCShowHighlightNotesPDFController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:configuration];
    self.delegate = self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forAnnotations:(NSArray<PSPDFAnnotation *> *)annotations inRect:(CGRect)annotationRect onPageView:(PSPDFPageView *)pageView {
    PSPDFAnnotation *annotation = annotations.count == 1 ? annotations.lastObject : nil;
    if (annotation.type == PSPDFAnnotationTypeHighlight) {
        // Show note controller directly, skipping the menu.
        [pageView showNoteControllerForAnnotation:annotation animated:YES];
        return @[];
    } else {
        return menuItems;
    }
}

@end
