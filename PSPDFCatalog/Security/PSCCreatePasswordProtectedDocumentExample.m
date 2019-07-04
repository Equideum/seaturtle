//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'CreatePasswordProtectedDocumentExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import <PSPDFKit/PSPDFProcessor.h>

@interface PSCCreatePasswordProtectedDocumentExample : PSCExample <PSPDFProcessorDelegate>
@property (nonatomic) PSPDFStatusHUDItem *status;
@end

@implementation PSCCreatePasswordProtectedDocumentExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Create password protected PDF";
        self.contentDescription = @"Password is 'test123'";
        self.category = PSCExampleCategorySecurity;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // create new file that is protected
    NSString *password = @"test123";
    NSURL *tempURL = PSCTempFileURLWithPathExtension(@"protected", @"pdf");
    PSPDFDocument *hackerMagDoc = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];

    self.status = [PSPDFStatusHUDItem progressWithText:[PSPDFLocalize(@"Preparing") stringByAppendingString:@"…"]];
    [self.status pushAnimated:YES completion:NULL];

    // By default, a newly initialized `PSPDFProcessorConfiguration` results in an exported Document that is the same as the input.
    PSPDFProcessorConfiguration *processorConfiguration = [[PSPDFProcessorConfiguration alloc] initWithDocument:hackerMagDoc];

    // Set the proper password and key length in the `PSPDFDocumentSecurityOptions`
    PSPDFDocumentSecurityOptions *documentSecurityOptions = [[PSPDFDocumentSecurityOptions alloc] initWithOwnerPassword:password userPassword:password keyLength:PSPDFDocumentSecurityOptionsKeyLengthAutomatic error:NULL];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:processorConfiguration securityOptions:documentSecurityOptions];

        [processor writeToFileURL:tempURL error:NULL];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.status popAnimated:YES completion:NULL];

            // show file
            PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:tempURL];
            PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

            [delegate.currentViewController.navigationController pushViewController:pdfController animated:YES];
        });
    });
    return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFProcessorDelegate

- (void)processor:(PSPDFProcessor *)processor didProcessPage:(NSUInteger)currentPage totalPages:(NSUInteger)totalPages {
    self.status.progress = currentPage / (float)totalPages;
}

@end
