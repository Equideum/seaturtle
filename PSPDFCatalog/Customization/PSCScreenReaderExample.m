//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCReaderPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>
@property (nonatomic) PSPDFSearchHighlightView *highlightView;
@property (nonatomic) NSTimer *wordTimer;
@property (nonatomic) PSPDFWord *currentWord;
@property (nonatomic, copy) NSArray *currentWords;
@end

@interface PSCScreenReaderExample : PSCExample
@end
@implementation PSCScreenReaderExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Screen Reader";
        self.contentDescription = @"Creates a sample interface for a screen-reader application";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 300;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSCReaderPDFViewController alloc] initWithDocument:document];
    pdfController.pageIndex = 1;
    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCReaderPDFViewController

@implementation PSCReaderPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    configuration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.pageMode = PSPDFPageModeSingle;
    }];
    [super commonInitWithDocument:document configuration:configuration];
    self.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startWordTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopWordTimer];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)startWordTimer {
    [self stopWordTimer];
    self.wordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(wordTimerFired:) userInfo:nil repeats:YES];
    [self wordTimerFired:self.wordTimer];
}

- (void)stopWordTimer {
    [self.wordTimer invalidate];
}

- (void)prepareNewPage {
    PSPDFTextParser *textParser = [self.document textParserForPageAtIndex:self.pageIndex];
    self.currentWord = nil;
    self.currentWords = textParser.words;
}

- (void)wordTimerFired:(NSTimer *)timer {
    if (!self.currentWords) {
        [self prepareNewPage];
    }

    if (!self.currentWord) {
        if (self.currentWords.count > 0) {
            self.currentWord = (self.currentWords)[0];
        }
    } else {
        NSUInteger index = [self.currentWords indexOfObjectIdenticalTo:self.currentWord];
        index++;
        if (index < self.currentWords.count) {
            self.currentWord = self.currentWords[index];
        } else {
            // we hit the end of the page.
            self.currentWord = nil;
        }
    }

    [self highlightWord:self.currentWord];

    // Stop timer if we ran out of words.
    if (!self.currentWord) {
        [self stopWordTimer];
    }
}

- (void)highlightWord:(PSPDFWord *)word {
    NSLog(@"Highlighting: %@", word.stringValue);
    PSPDFSearchHighlightView *highlightView;

    // we (ab)use the search highlight system here.
    PSPDFDocument *document = self.document;
    PSPDFTextParser *textParser = [self.document textParserForPageAtIndex:self.pageIndex];
    NSArray<PSPDFGlyph *> *glyphs = [textParser glyphsInRange:word.range];
    if (document != nil && glyphs.count > 0) {
        PSPDFTextBlock *selection = [[PSPDFTextBlock alloc] initWithGlyphs:glyphs frame:CGRectNull];
        PSPDFSearchResult *searchResult = [[PSPDFSearchResult alloc] initWithDocument:document pageIndex:self.pageIndex range:NSMakeRange(NSNotFound, 0) previewText:@"" rangeInPreviewText:NSMakeRange(NSNotFound, 0) selection:selection annotation:nil];
        highlightView = [[PSPDFSearchHighlightView alloc] initWithFrame:CGRectZero];
        highlightView.searchResult = searchResult;
    }
    self.highlightView = highlightView;
}

- (void)setHighlightView:(PSPDFSearchHighlightView *)highlightView {
    if (highlightView != _highlightView) {
        [_highlightView removeFromSuperview];
        _highlightView = highlightView;

        PSPDFPageView *pageView = [self pageViewForPageAtIndex:self.pageIndex];
        [pageView addSubview:highlightView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

// Restart on new page.
- (void)pdfViewController:(PSPDFViewController *)pdfController willBeginDisplayingPageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    [self prepareNewPage];
    [self startWordTimer];
}

// Pause when in thumbnail view.
- (void)pdfViewController:(PSPDFViewController *)pdfController didChangeViewMode:(PSPDFViewMode)viewMode {
    if (viewMode == PSPDFViewModeThumbnails) {
        [self stopWordTimer];
    } else {
        [self startWordTimer];
    }
}

@end
