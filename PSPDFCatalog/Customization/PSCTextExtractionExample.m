//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCExample.h"
#import "PSCFileHelper.h"

@interface PSCFullTextSearchExample : PSCExample <PSPDFDocumentPickerControllerDelegate>
@end
@implementation PSCFullTextSearchExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Full-Text Search";
        self.contentDescription = @"Use PSPDFDocumentPickerController to perform a full-text search across all sample documents.";
        self.category = PSCExampleCategoryTextExtraction;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocumentPickerController *documentPicker = [[PSPDFDocumentPickerController alloc] initWithDirectory:@"/Bundle/Samples" includeSubdirectories:YES library:PSPDFKit.sharedInstance.library];
    documentPicker.delegate = self;
    documentPicker.fullTextSearchEnabled = YES;
    return documentPicker;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocumentPickerControllerDelegate

- (void)documentPickerController:(PSPDFDocumentPickerController *)controller didSelectDocument:(PSPDFDocument *)document pageIndex:(PSPDFPageIndex)pageIndex searchString:(NSString *)searchString {
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.pageIndex = pageIndex;
    [pdfController.navigationItem setRightBarButtonItems:@[pdfController.thumbnailsButtonItem, pdfController.annotationButtonItem, pdfController.outlineButtonItem, pdfController.searchButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    [controller.navigationController pushViewController:pdfController animated:YES];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCConvertMarkupStringToPDFExample

@interface PSCConvertMarkupStringToPDFExample : PSCExample
@end
@implementation PSCConvertMarkupStringToPDFExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Convert markup string to PDF";
        self.contentDescription = @"Convert a HTML-like string to PDF.";
        self.category = PSCExampleCategoryTextExtraction;
        self.priority = 20;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    UIAlertController *websitePrompt = [UIAlertController alertControllerWithTitle:@"Markup String" message:@"Experimental feature. Basic HTML is allowed." preferredStyle:UIAlertControllerStyleAlert];
    [websitePrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = @"<br><br><br><h1>This is a <i>test</i> in <span style='color:red'>color.</span></h1>";
    }];
    __weak UIAlertController *weakWebsitePrompt = websitePrompt;
    [websitePrompt addAction:[UIAlertAction actionWithTitle:@"Convert" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Get data
        NSString *html = weakWebsitePrompt.textFields.firstObject.text ?: @"";
        NSURL *outputURL = PSCTempFileURLWithPathExtension(@"converted", @"pdf");

        // start the conversion
        PSPDFStatusHUDItem *status = [PSPDFStatusHUDItem indeterminateProgressWithText:@"Converting..."];
        [status setHUDStyle:PSPDFStatusHUDStyleBlack];
        [status pushAnimated:YES completion:NULL];

        NSDictionary *options = @{ PSPDFProcessorNumberOfPagesKey: @(1), PSPDFProcessorDocumentTitleKey: @"Generated PDF" };

        PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithOptions:options];

        [processor convertHTMLString:html outputFileURL:outputURL completionBlock:^(NSError *_Nullable error) {

            // Update status to done.
            PSPDFStatusHUDItem *statusDone = [PSPDFStatusHUDItem successWithText:@"Done"];
            [statusDone pushAndPopWithDelay:2 animated:YES completion:NULL];
            [status popAnimated:YES completion:NULL];

            // Generate document and show it.
            PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:outputURL];
            PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

            [delegate.currentViewController.navigationController pushViewController:pdfController animated:YES];
        }];
    }]];

    [websitePrompt addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    [delegate.currentViewController presentViewController:websitePrompt animated:YES completion:NULL];

    return nil;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCConvertWebsiteOrFilesToPDFExample

@interface PSCConvertWebsiteOrFilesToPDFExample : PSCExample
@end
@implementation PSCConvertWebsiteOrFilesToPDFExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Convert Website/Files to PDF";
        self.contentDescription = @"Use PSPDFProcessor to convert web sites or office documents directly to PDF.";
        self.category = PSCExampleCategoryTextExtraction;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    UIAlertController *websitePrompt = [UIAlertController alertControllerWithTitle:@"URL (File/Website) to convert" message:@"Convert websites or files to PDF (Word, Pages, Keynote, ...).\nNote: This is an unsupported feature." preferredStyle:UIAlertControllerStyleAlert];
    [websitePrompt addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = @"https://google.com";
    }];
    [websitePrompt addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    __weak UIAlertController *weakWebsitePrompt = websitePrompt;
    UIViewController *currentViewController = delegate.currentViewController;
    [websitePrompt addAction:[UIAlertAction actionWithTitle:@"Convert" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // get URL
        NSString *website = weakWebsitePrompt.textFields.firstObject.text ?: @"";
        if (![website.lowercaseString hasPrefix:@"http"]) website = [NSString stringWithFormat:@"http://%@", website];
        NSURL *URL = [NSURL URLWithString:website];
        NSURL *outputURL = PSCTempFileURLWithPathExtension(@"converted", @"pdf");
        // URL = [NSURL fileURLWithPath:PSPDFResolvePathNames(@"/Bundle/Samples/test2.key", nil)];

        // start the conversion
        PSPDFStatusHUDItem *status = [PSPDFStatusHUDItem indeterminateProgressWithText:@"Converting..."];
        status.HUDStyle = PSPDFStatusHUDStyleBlack;
        [status pushAnimated:YES completion:NULL];

        NSDictionary *options = @{PSPDFProcessorPageBorderMarginKey: [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)]};

        PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithOptions:options];

        [processor generatePDFFromURL:URL outputFileURL:outputURL completionBlock:^(NSURL *fileURL, NSError *error) {
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Conversion failed" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:NULL]];
                [status popAnimated:YES completion:^{
                    [currentViewController presentViewController:alert animated:YES completion:NULL];
                }];
            } else {
                // generate document and show it
                PSPDFStatusHUDItem *statusDone = [PSPDFStatusHUDItem successWithText:@"Done"];
                [statusDone pushAndPopWithDelay:2.0 animated:YES completion:NULL];
                [status popAnimated:YES completion:NULL];

                PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:fileURL];
                PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

                [delegate.currentViewController.navigationController pushViewController:pdfController animated:YES];
            }
        }];
    }]];
    [currentViewController presentViewController:websitePrompt animated:YES completion:NULL];

    return nil;
}

@end
