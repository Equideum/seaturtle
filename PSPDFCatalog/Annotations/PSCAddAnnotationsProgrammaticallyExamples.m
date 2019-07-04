//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'AddAnnotationsProgrammaticallyExamples.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"

/// This file hosts various examples that show how to programmatically create different annotation types.

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAddInkAnnotationProgrammaticallyExample

@interface PSCAddInkAnnotationProgrammaticallyExample : PSCExample
@end
@implementation PSCAddInkAnnotationProgrammaticallyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add Ink Annotation";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled; // don't confuse other examples.

    // add ink annotation if there isn't one already.
    NSUInteger targetPage = 0;
    if ([document annotationsForPageAtIndex:targetPage type:PSPDFAnnotationTypeInk].count == 0) {
        PSPDFInkAnnotation *annotation = [PSPDFInkAnnotation new];

        // example how to create a line rect.
        NSArray *lines = @[
            @[@(CGPointMake(100, 100)), @(CGPointMake(100, 200)), @(CGPointMake(150, 300))], // first line
            @[@(CGPointMake(200, 100)), @(CGPointMake(200, 200)), @(CGPointMake(250, 300))] // second line
        ];

        // convert view line points into PDF line points.
        PSPDFPageInfo *pageInfo = [document pageInfoForPageAtIndex:targetPage];
        CGRect viewRect = UIScreen.mainScreen.bounds; // this is your drawing view rect - we don't have one yet, so lets just assume the whole screen for this example. You can also directly write the points in PDF coordinate space, then you don't need to convert, but usually your user draws and you need to convert the points afterwards.
        annotation.lineWidth = 5;
        annotation.lines = PSPDFConvertViewLinesToPDFLines(lines, pageInfo, viewRect);

        annotation.color = [UIColor colorWithRed:0.667 green:0.279 blue:0.748 alpha:1.];
        annotation.pageIndex = targetPage;
        [document addAnnotations:@[annotation] options:nil];
    }

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAddHighlightAnnotationProgrammaticallyExample

@interface PSCAddHighlightAnnotationProgrammaticallyExample : PSCExample
@end
@implementation PSCAddHighlightAnnotationProgrammaticallyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add Highlight Annotations";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 20;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled; // don't confuse other examples.

    // Let's create a highlight for all occurences of "bow" on the first 10 pages, in Orange.
    NSUInteger annotationCounter = 0;
    for (NSUInteger pageIndex = 0; pageIndex < 10; pageIndex++) {
        PSPDFTextParser *textParser = [document textParserForPageAtIndex:pageIndex];
        for (PSPDFWord *word in textParser.words) {
            if ([word.stringValue isEqualToString:@"bow"]) {
                PSPDFHighlightAnnotation *annotation = [PSPDFHighlightAnnotation textOverlayAnnotationWithGlyphs:[textParser glyphsInRange:word.range]];
                annotation.color = UIColor.orangeColor;
                annotation.contents = [NSString stringWithFormat:@"This is an automatically created highlight #%tu", annotationCounter];
                annotation.pageIndex = pageIndex;
                [document addAnnotations:@[annotation] options:nil];
                annotationCounter++;
            }
        }
    }

    // Highlight an entire text selection on the second page, in yellow.
    NSUInteger pageIndex = 1;
    // Text selection rect in PDF coordinates for the first paragraph of the second page.
    CGRect textSelectionRect = CGRectMake(36.0, 547.0, 238.0, 135.0);
    NSArray <PSPDFGlyph *> *glyphs = [document objectsAtPDFRect:textSelectionRect pageIndex:pageIndex options:@{PSPDFObjectsGlyphsKey : @YES}][PSPDFObjectsGlyphsKey];
    PSPDFHighlightAnnotation *annotation = [PSPDFHighlightAnnotation textOverlayAnnotationWithGlyphs:glyphs];
    annotation.color = UIColor.yellowColor;
    annotation.contents = [NSString stringWithFormat:@"This is an automatically created highlight #%tu", annotationCounter];
    annotation.pageIndex = pageIndex;
    [document addAnnotations:@[annotation] options:nil];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    controller.pageIndex = pageIndex;
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsProgramaticallyCreateAnnotationsExample

@interface PSCAnnotationsProgramaticallyCreateAnnotationsExample : PSCExample
@end
@implementation PSCAnnotationsProgramaticallyCreateAnnotationsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add Note Annotation";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *hackerMagURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameAnnualReport];

    // we use a NSData document here but it'll work even better with a file-based variant.
    NSData *data = [NSData dataWithContentsOfURL:hackerMagURL options:NSDataReadingMappedIfSafe error:NULL];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[[[PSPDFDataContainerProvider alloc] initWithData:data]]];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;
    document.title = @"Programmatically create annotations";

    NSMutableArray *annotations = [NSMutableArray array];
    CGFloat maxHeight = [document pageInfoForPageAtIndex:0].size.height;
    for (int i = 0; i < 5; i++) {
        PSPDFNoteAnnotation *noteAnnotation = [PSPDFNoteAnnotation new];
        // width/height will be ignored for note annotations.
        noteAnnotation.boundingBox = CGRectMake(100.0, 50.0 + i * maxHeight / 5, 32.0, 32.0);
        noteAnnotation.contents = [NSString stringWithFormat:@"Note %d", 5 - i]; // notes are added bottom-up
        [annotations addObject:noteAnnotation];
    }
    [document addAnnotations:annotations options:nil];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAddPolyLineAnnotationProgrammaticallyExample

@interface PSCAddPolyLineAnnotationProgrammaticallyExample : PSCExample
@end
@implementation PSCAddPolyLineAnnotationProgrammaticallyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add PolyLine Annotation";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 40;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled; // don't confuse other examples
    // add shape annotation if there isn't one already.
    NSUInteger pageIndex = 0;
    if ([document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypePolyLine].count == 0) {
        PSPDFPolyLineAnnotation *polyline = [PSPDFPolyLineAnnotation new];
        polyline.points = @[@(CGPointMake(152, 333)), @(CGPointMake(167, 372)), @(CGPointMake(231, 385)), @(CGPointMake(278, 354)), @(CGPointMake(215, 322))];
        polyline.color = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.];
        polyline.fillColor = UIColor.yellowColor;
        polyline.lineEnd2 = PSPDFLineEndTypeClosedArrow;
        polyline.lineWidth = 5.0;
        polyline.pageIndex = pageIndex;
        [document addAnnotations:@[polyline] options:nil];
    }

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.openInButtonItem, controller.searchButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAddShapeAnnotationProgrammaticallyExample

@interface PSCAddShapeAnnotationProgrammaticallyExample : PSCExample
@end
@implementation PSCAddShapeAnnotationProgrammaticallyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add Shape Annotation";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled; // don't confuse other examples
    // add shape annotation if there isn't one already.
    NSUInteger pageIndex = 0;
    if ([document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeSquare].count == 0) {
        PSPDFSquareAnnotation *annotation = [[PSPDFSquareAnnotation alloc] init];
        annotation.boundingBox = CGRectInset((CGRect){.size = [document pageInfoForPageAtIndex:pageIndex].size}, 100, 100);
        annotation.color = [UIColor colorWithRed:0.0 green:100.0 / 255. blue:0.0 alpha:1.];
        annotation.fillColor = annotation.color;
        annotation.alpha = 0.5;
        annotation.pageIndex = pageIndex;
        [document addAnnotations:@[annotation] options:nil];
    }

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.textSelectionEnabled = NO;
    }]];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.openInButtonItem, controller.searchButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAddVectorStampAnnotationProgrammaticallyExample

@interface PSCAddVectorStampAnnotationProgrammaticallyExample : PSCExample
@end
@implementation PSCAddVectorStampAnnotationProgrammaticallyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add Vector Stamp Annotation";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 60;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *sourceURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameQuickStart];
    NSURL *writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, NO);
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:writableURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;
    NSURL *logoURL = [samplesURL URLByAppendingPathComponent:@"PSPDFKit Logo.pdf"];

    // Add stamp annotation if there isn't one already.
    NSUInteger pageIndex = 0;
    if ([document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeStamp].count == 0) {
        // Add a transparent stamp annotation using the appearance stream generator.
        PSPDFStampAnnotation *stampAnnotation = [[PSPDFStampAnnotation alloc] init];
        stampAnnotation.appearanceStreamGenerator = [[PSPDFFileAppearanceStreamGenerator alloc] initWithFileURL:logoURL];
        stampAnnotation.boundingBox = CGRectMake(180.0, 150.0, 444.0, 500.0);
        stampAnnotation.pageIndex = pageIndex;
        [document addAnnotations:@[stampAnnotation] options:nil];
    }
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAddFileAnnotationProgrammaticallyExample

@interface PSCAddFileAnnotationProgrammaticallyExample : PSCExample
@end
@implementation PSCAddFileAnnotationProgrammaticallyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add File Annotation With Embedded File";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 70;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *sourceURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameQuickStart];
    NSURL *writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, NO);
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:writableURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;
    NSURL *embeddedFileURL = [samplesURL URLByAppendingPathComponent:@"PSPDFKit Logo.pdf"];

    // Add file annotation if there isn't one already.
    NSUInteger pageIndex = 0;
    if ([document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeFile].count == 0) {
        // Create a file annotation.
        PSPDFFileAnnotation *fileAnnotation = [[PSPDFFileAnnotation alloc] init];
        fileAnnotation.pageIndex = pageIndex;
        fileAnnotation.iconName = PSPDFFileIconNameGraph;
        fileAnnotation.color = UIColor.blueColor;
        fileAnnotation.boundingBox = CGRectMake(500.0, 250.0, 32.0, 32.0);

        // Create an embedded file and add it to the file annotation.
        PSPDFEmbeddedFile *embeddedFile = [[PSPDFEmbeddedFile alloc] initWithFileURL:embeddedFileURL fileDescription:@"PSPDFKit logo"];
        fileAnnotation.embeddedFile = embeddedFile;
        [document addAnnotations:@[fileAnnotation] options:nil];
    }
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end
