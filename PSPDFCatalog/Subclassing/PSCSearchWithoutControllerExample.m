//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

/// Example how to have a "persistent" search mode.
@interface PSCHeadlessSearchPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>

@property (nonatomic, copy, nullable) NSString *highlightedSearchText;

@end

@interface PSCSearchWithoutControllerExample : PSCExample
@end
@implementation PSCSearchWithoutControllerExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Headless search example";
        self.contentDescription = @"Search programatically without displaying search controller.";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 140;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSCHeadlessSearchPDFViewController *pdfController = [[PSCHeadlessSearchPDFViewController alloc] initWithDocument:document];
    pdfController.highlightedSearchText = @"is";
    return pdfController;
}

@end

@interface PSCNonAnimatingSearchHighlightView : PSPDFSearchHighlightView
@end

@implementation PSCHeadlessSearchPDFViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:[configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {

                                               // register the override to use a custom search highlight view subclass.
                                               [builder overrideClass:PSPDFSearchHighlightView.class withClass:PSCNonAnimatingSearchHighlightView.class];
                                           }]];

    // we are using the delegate to be informed about page loads.
    self.delegate = self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didConfigurePageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    // restart search if we have a new pageView loaded.
    [self updateTextHighlight];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

- (void)setHighlightedSearchText:(nullable NSString *)highlightedSearchText {
    if (highlightedSearchText != _highlightedSearchText) {
        _highlightedSearchText = [highlightedSearchText copy];
        [self updateTextHighlight];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)updateTextHighlight {
    [self searchForString:self.highlightedSearchText options:@{ PSPDFViewControllerSearchHeadlessKey: @YES } sender:nil animated:NO];
}

@end

@implementation PSCNonAnimatingSearchHighlightView

// NOP
- (void)popupAnimation {
}

@end
