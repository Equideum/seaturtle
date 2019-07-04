//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCMergeDocumentsViewController.h"

#import "PSCDragResizableSplitView.h"
#import "PSCFileHelper.h"

@interface PSCMergePDFViewController : PSPDFViewController
@end

@interface PSCMergeDocumentsViewController () <PSPDFDocumentPickerControllerDelegate>
@property (nonatomic) UINavigationController *leftNavigator;
@property (nonatomic) UINavigationController *rightNavigator;
@property (nonatomic) PSCMergePDFViewController *leftController;
@property (nonatomic) PSCMergePDFViewController *rightController;
/// This is a forward of the view property (@see -loadView)
@property (nonatomic, readonly) PSCDragResizableSplitView *draggableSplitView;
@end

@implementation PSCMergeDocumentsViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.edgesForExtendedLayout = UIRectEdgeAll & ~UIRectEdgeTop;
        self.title = @"Merge Documents";
    }
    return self;
}

- (instancetype)initWithLeftDocument:(PSPDFDocument *)leftDocument rightDocument:(PSPDFDocument *)rightDocument {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        _leftDocument = leftDocument;
        _rightDocument = rightDocument;
    }
    return self;
}

- (PSCDragResizableSplitView *)draggableSplitView {
    return (PSCDragResizableSplitView *)self.view;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)loadView {
    self.view = [PSCDragResizableSplitView new];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize left controller.
    self.leftController = [[PSCMergePDFViewController alloc] initWithDocument:self.leftDocument];
    self.leftController.title = @"Their Version";
    self.leftNavigator = [[UINavigationController alloc] initWithRootViewController:self.leftController];

    // Initialize right controller.
    self.rightController = [[PSCMergePDFViewController alloc] initWithDocument:self.rightDocument];
    self.rightController.title = @"Your Version";
    self.rightNavigator = [[UINavigationController alloc] initWithRootViewController:self.rightController];

    // Establish the parent/child relationships, installing the views
    [self addChildViewController:self.rightNavigator];
    [self addChildViewController:self.leftNavigator];
    UIView *leftView = self.leftNavigator.view;
    UIView *rightView = self.rightNavigator.view;
    [self.draggableSplitView installLeftView:leftView rightView:rightView];
    [self.leftNavigator didMoveToParentViewController:self];
    [self.rightNavigator didMoveToParentViewController:self];

    // Stlye the views
    leftView.tintColor = self.navigationController.navigationBar.barTintColor;
    rightView.tintColor = self.navigationController.navigationBar.barTintColor;

    // Allow to change source document.
    UIBarButtonItem *loadDocumentButton = [[UIBarButtonItem alloc] initWithTitle:@"Source" style:UIBarButtonItemStylePlain target:self action:@selector(selectLeftSource:)];
    self.leftController.navigationItem.leftBarButtonItems = @[loadDocumentButton];

    // Allow to save document
    UIBarButtonItem *saveDocument = [[UIBarButtonItem alloc] initWithTitle:@"Save Document" style:UIBarButtonItemStylePlain target:self action:@selector(saveDocument)];
    self.rightController.navigationItem.leftBarButtonItems = @[saveDocument];

    // Page modification bar
    UIBarButtonItem *addPage = [[UIBarButtonItem alloc] initWithTitle:@"Add Page" style:UIBarButtonItemStylePlain target:self action:@selector(addPage)];
    UIBarButtonItem *replacePage = [[UIBarButtonItem alloc] initWithTitle:@"Replace Page" style:UIBarButtonItemStylePlain target:self action:@selector(replacePage)];
    UIBarButtonItem *removePage = [[UIBarButtonItem alloc] initWithTitle:@"Remove Page" style:UIBarButtonItemStylePlain target:self action:@selector(removePage)];

    UIBarButtonItem *mergeAnnotations = [[UIBarButtonItem alloc] initWithTitle:@"Merge Annotations" style:UIBarButtonItemStylePlain target:self action:@selector(mergeAnnotations)];
    UIBarButtonItem *replaceAnnotations = [[UIBarButtonItem alloc] initWithTitle:@"Replace Annotations" style:UIBarButtonItemStylePlain target:self action:@selector(replaceAnnotations)];

    UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    spacing.width = 30.0;
    self.navigationItem.rightBarButtonItems = @[mergeAnnotations, replaceAnnotations, spacing, addPage, replacePage, removePage];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

- (void)setLeftDocument:(PSPDFDocument *)leftDocument {
    if (leftDocument != _leftDocument) {
        _leftDocument = leftDocument;
        self.leftController.document = leftDocument;
    }
}

- (void)setRightDocument:(PSPDFDocument *)rightDocument {
    if (rightDocument != _rightDocument) {
        _rightDocument = rightDocument;
        self.rightController.document = rightDocument;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions

- (void)addPage {
    [self updateDocumentWithMutatingFiles:^(NSMutableArray<NSURL *> *files) {
        NSURL *newFile = self.leftDocument.fileURLs[self.leftController.pageIndex];
        [files insertObject:newFile atIndex:self.rightController.pageIndex];
    }];
}

// Replace visble page on the left with the right one.
- (void)replacePage {
    [self updateDocumentWithMutatingFiles:^(NSMutableArray<NSURL *> *files) {
        NSURL *replacementFile = self.leftDocument.fileURLs[self.leftController.pageIndex];
        files[self.rightController.pageIndex] = replacementFile;
    }];
}

- (void)removePage {
    [self updateDocumentWithMutatingFiles:^(NSMutableArray<NSURL *> *files) {
        [files removeObjectAtIndex:self.rightController.pageIndex];
    }];
}

- (void)updateDocumentWithMutatingFiles:(void (^)(NSMutableArray<NSURL *> *files))fileMutationBlock {
    [self.rightDocument saveWithOptions:nil error:nil]; // always save.
    [self splitAllDocumentsIfRequired];

    NSMutableArray<NSURL *> *fileURLs = [self.rightDocument.fileURLs mutableCopy];
    fileMutationBlock(fileURLs);

    // Create new document and preserve the provider customization block.

    NSMutableArray<PSPDFCoordinatedFileDataProvider *> *dataProviders = [NSMutableArray array];
    for (NSURL *fileURL in fileURLs) {
        [dataProviders addObject:[[PSPDFCoordinatedFileDataProvider alloc] initWithFileURL:fileURL]];
    }

    PSPDFDocument *newDocument = [[PSPDFDocument alloc] initWithDataProviders:dataProviders];
    newDocument.UID = self.rightDocument.UID; // Preserve the UID for the annotation store.
    newDocument.didCreateDocumentProviderBlock = self.rightDocument.didCreateDocumentProviderBlock;

    // Clear old cache. This is not required, but a good thing to do.
    // The new document will have a new autogenerated UID since the files array changed.
    [PSPDFKit.sharedInstance.cache removeCacheForDocument:self.rightDocument];

    [self performWithPreservingPages:^{
        self.rightDocument = newDocument;
    }];
}

- (void)mergeAnnotations {
    NSUInteger page = self.rightController.pageIndex;

    // Build set of current annotation names.
    NSArray<PSPDFAnnotation *> *currentAnnotations = [self.rightDocument annotationsForPageAtIndex:page type:PSPDFAnnotationTypeAll & ~PSPDFAnnotationTypeLink];
    NSMutableSet<NSString *> *currentNames = [NSMutableSet set];
    for (PSPDFAnnotation *currentAnnotation in currentAnnotations) {
        NSString *name = currentAnnotation.name;
        if (name.length > 0) [currentNames addObject:name];
    }

    // Extract annotations from left document.
    NSArray<PSPDFAnnotation *> *newAnnotations = [self.leftDocument annotationsForPageAtIndex:self.leftController.pageIndex type:PSPDFAnnotationTypeAll & ~PSPDFAnnotationTypeLink];
    for (PSPDFAnnotation *annotation in newAnnotations) {
        NSString *name = annotation.name;
        // Check if we already have an annotation with the same name in the document, and delete if so.
        if (name && [currentNames containsObject:name]) {
            for (PSPDFAnnotation *currentAnnotation in currentAnnotations) {
                if ([currentAnnotation.name isEqualToString:name]) {
                    [self.rightDocument removeAnnotations:@[currentAnnotation] options:nil];
                    break;
                }
            }
        }

        // Copy annotation object - else we would remove them from the current document.
        PSPDFAnnotation *copiedAnnotation = [annotation copy];
        copiedAnnotation.absolutePageIndex = page;
        [self.rightDocument addAnnotations:@[copiedAnnotation] options:nil];
    }
}

- (void)clearAnnotations {
    // Clear all current annotations (except links)
    NSArray *currentAnnotations = [self.rightDocument annotationsForPageAtIndex:self.rightController.pageIndex type:PSPDFAnnotationTypeAll & ~PSPDFAnnotationTypeLink];
    [self.rightDocument removeAnnotations:currentAnnotations options:nil];
}

- (void)replaceAnnotations {
    [self clearAnnotations];
    [self mergeAnnotations];
}

- (void)saveDocument {
    // Save current and create the new document.
    [self.rightDocument saveWithOptions:nil error:nil];
    [self.rightController reloadData];

    NSURL *savedDocumentURL = PSCTempFileURLWithPathExtension(@"final", @"pdf");
    PSPDFProcessorConfiguration *configuration = [[PSPDFProcessorConfiguration alloc] initWithDocument:self.rightDocument];
    PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:configuration securityOptions:nil];

    [processor writeToFileURL:savedDocumentURL error:NULL];

    // Present the new document.
    PSPDFDocument *savedDocument = [[PSPDFDocument alloc] initWithURL:savedDocumentURL];
    PSPDFViewController *resultController = [[PSPDFViewController alloc] initWithDocument:savedDocument];
    resultController.navigationItem.rightBarButtonItems = @[resultController.thumbnailsButtonItem, resultController.searchButtonItem, resultController.outlineButtonItem, resultController.emailButtonItem, resultController.openInButtonItem];
    UINavigationController *resultsNavController = [[UINavigationController alloc] initWithRootViewController:resultController];
    [self.navigationController presentViewController:resultsNavController animated:YES completion:NULL];
}

- (void)selectLeftSource:(id)sender {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    PSPDFDocumentPickerController *documentPicker = [[PSPDFDocumentPickerController alloc] initWithDirectory:samplesURL.path includeSubdirectories:NO library:Nil];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationPopover;

    [self.leftController presentViewController:documentPicker options:@{ PSPDFPresentationInNavigationControllerKey: @YES } animated:YES sender:sender completion:NULL];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)performWithPreservingPages:(void (^)(void))block {
    NSUInteger leftPage = self.leftController.pageIndex;
    NSUInteger rightPage = self.rightController.pageIndex;
    block();
    self.leftController.pageIndex = leftPage;
    self.rightController.pageIndex = rightPage;
}

- (void)splitAllDocumentsIfRequired {
    [self performWithPreservingPages:^{
        // Splitting up the left document is wasteful - we could extract the file on-the-fly,
        // but for the sake of this simple example we just split the whole document.
        self.leftDocument = [self splitDocumentIfRequired:self.leftDocument saveAnnotationsInsidePDF:YES];
        self.rightDocument = [self splitDocumentIfRequired:self.rightDocument saveAnnotationsInsidePDF:YES];
    }];
}

// To make the right document customizable, we need to split it up into single pages.
// TODO: Misses progress display and error handling.
- (PSPDFDocument *)splitDocumentIfRequired:(PSPDFDocument *)document saveAnnotationsInsidePDF:(BOOL)saveAnnotationsInsidePDF {
    if (document.isValid && document.fileURLs.count != document.pageCount) {
        NSMutableArray<PSPDFCoordinatedFileDataProvider *> *dataProviders = [NSMutableArray array];
        for (NSUInteger pageIndex = 0; pageIndex < document.pageCount; pageIndex++) {
            NSURL *splitURL = PSCTempFileURLWithPathExtension([NSString stringWithFormat:@"%@_split_%tu", document.fileURL.lastPathComponent, pageIndex], @"pdf");

            // Generate split files
            PSPDFProcessorConfiguration *configuration = [[PSPDFProcessorConfiguration alloc] initWithDocument:document];
            if (!saveAnnotationsInsidePDF) {
                [configuration modifyAnnotationsOfTypes:PSPDFAnnotationTypeAll change:PSPDFAnnotationChangeRemove];
            }
            [configuration includeOnlyIndexes:[NSIndexSet indexSetWithIndex:pageIndex]];

            PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:configuration securityOptions:nil];

            [processor writeToFileURL:splitURL error:NULL];
            [dataProviders addObject:[[PSPDFCoordinatedFileDataProvider alloc] initWithFileURL:splitURL]];
        }
        return [[PSPDFDocument alloc] initWithDataProviders:dataProviders];
    }
    return document;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocumentPickerControllerDelegate

- (void)documentPickerController:(PSPDFDocumentPickerController *)controller didSelectDocument:(PSPDFDocument *)document pageIndex:(PSPDFPageIndex)pageIndex searchString:(NSString *)searchString {
    self.leftDocument = document;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCMergePDFViewController

@implementation PSCMergePDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    configuration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.userInterfaceViewMode = PSPDFUserInterfaceViewModeAlways;

        // prevent two-page mode.
        builder.pageMode = PSPDFPageModeSingle;

        // We already set the title at controller generation time.
        builder.allowToolbarTitleChange = NO;

        // Disable the long press menu.
        builder.createAnnotationMenuEnabled = NO;

        // fit 3 thumbs nicely next to each other on iPad/landscape.
        builder.thumbnailSize = CGSizeMake(150.0, 200.0);
    }];
    [super commonInitWithDocument:document configuration:configuration];

    // hide close button
    self.navigationItem.leftBarButtonItems = nil;

    self.navigationItem.rightBarButtonItems = @[self.thumbnailsButtonItem, self.outlineButtonItem, self.annotationButtonItem];

    // If the annotation toolbar is invoked, there's not enough space for the default configuration.
    self.annotationToolbarController.annotationToolbar.editableAnnotationTypes = [NSSet setWithObjects:PSPDFAnnotationStringHighlight, PSPDFAnnotationStringFreeText, PSPDFAnnotationStringNote, PSPDFAnnotationStringInk, PSPDFAnnotationStringStamp, nil];

    // Hide bookmark filter
    self.thumbnailController.filterOptions = @[PSPDFThumbnailViewFilterShowAll, PSPDFThumbnailViewFilterAnnotations];
    [self updateDocumentSettings:document];
}

- (void)setDocument:(PSPDFDocument *)document {
    [self updateDocumentSettings:document];
    super.document = document;
}

- (void)updateDocumentSettings:(PSPDFDocument *)document {
    // We don't care about bookmarks.
    document.bookmarksEnabled = NO;
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded; // only allow saving into the PDF.
}

@end
