//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "UIBarButtonItem+PSCBlockSupport.h"
#import <PSPDFKit/PSPDFProcessor.h>

NS_ASSUME_NONNULL_BEGIN

@interface PSCXFDFAnnotationProviderExample : PSCExample
@end
@implementation PSCXFDFAnnotationProviderExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"XFDF Annotation Provider";
        self.contentDescription = @"XFDF is an XML-based Adobe standard and a perfect format for syncing annotations/form values with a server.";
        self.category = PSCExampleCategoryAnnotationProviders;
        self.priority = 80;
    }
    return self;
}

// This example shows how you can create an XFDF provider instead of the default file-based one.
// XFDF is an industry standard and the file will be interopable with Adobe Acrobat or any other standard-compliant PDF framework.
- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *documentURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    // Load from an example XFDF file.
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSURL *fileXML = [NSURL fileURLWithPath:[docsFolder stringByAppendingPathComponent:@"XFDFTest.xfdf"]];
    NSLog(@"Using XFDF file at %@", fileXML.path);

    // Create an example XFDF from the current document if one doesn't already exist.
    //[NSFileManager.defaultManager removeItemAtURL:fileXML error:NULL]; // DEBUG HELPER: delete existing file.
    if (![NSFileManager.defaultManager fileExistsAtPath:(NSString *)fileXML.path]) {
        // Collect all existing annotations from the document
        PSPDFDocument *tempDocument = [[PSPDFDocument alloc] initWithURL:documentURL];
        NSMutableArray *annotations = [NSMutableArray array];
        for (NSArray *pageAnnots in [tempDocument allAnnotationsOfType:PSPDFAnnotationTypeAll].allValues) {
            [annotations addObjectsFromArray:pageAnnots];
        }
        // Write the file
        NSError *error;
        PSPDFFileDataSink *dataSink = [[PSPDFFileDataSink alloc] initWithFileURL:fileXML options:PSPDFDataSinkOptionNone error:&error];
        if (dataSink) {
            if (![[PSPDFXFDFWriter new] writeAnnotations:annotations toDataSink:dataSink documentProvider:tempDocument.documentProviders[0] error:&error]) {
                NSLog(@"Failed to write XFDF file: %@", error.localizedDescription);
            }
        } else {
            NSLog(@"Failed to open XFDF file: %@", error.localizedDescription);
        }
    }

    // Create document and set up the XFDF provider.
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;
    document.didCreateDocumentProviderBlock = ^(PSPDFDocumentProvider *documentProvider) {
        PSPDFXFDFAnnotationProvider *XFDFProvider = [[PSPDFXFDFAnnotationProvider alloc] initWithDocumentProvider:documentProvider fileURL:fileXML];
        // Note that if the document you're opening has form fields which you wish to be usable when using XFDF, you should also add the file annotation
        // provider to the annotation manager's `annotationProviders` array:
        //
        // PSPDFFileAnnotationProvider *fileProvider = documentProvider.annotationManager.fileAnnotationProvider;
        // documentProvider.annotationManager.annotationProviders = @[XFDFProvider, fileProvider];
        //
        documentProvider.annotationManager.annotationProviders = @[XFDFProvider];
    };

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain block:^(id sender) {
        [document saveWithOptions:nil completionHandler:^(NSError *error, NSArray *savedAnnotations) {
            if (!error) {
                unsigned long long XFDFFileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:(NSString *)fileXML.path error:NULL] fileSize];
                NSLog(@"Saving done. (XFDF file size: %lld)", XFDFFileSize);
            } else {
                NSLog(@"Saving failed: %@", error.localizedDescription);
            }
        }];
    }];
    controller.navigationItem.leftBarButtonItems = @[controller.closeButtonItem, saveButton];
    return controller;
}

@end

@interface PSCEncryptedXFDFAnnotationProviderExample : PSCExample
@end
@implementation PSCEncryptedXFDFAnnotationProviderExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"XFDF Annotation Provider, Encrypted";
        self.contentDescription = @"Variant that encrypts/decrypts the XFDF file on-the-fly.";
        self.category = PSCExampleCategoryAnnotationProviders;
        self.priority = 81;
    }
    return self;
}

// This example shows how you can create an XFDF provider instead of the default file-based one.
// XFDF is an industry standard and the file will be interopable with Adobe Acrobat or any other standard-compliant PDF framework.
- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *documentURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    // Load from an example XFDF file.
    NSString *(^passphraseProvider)(void) = ^NSString *{
        return @"jJ9A3BiMXoq+rEoYMdqBoBNzgxagTf";
    };
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSURL *fileXML = [NSURL fileURLWithPath:[docsFolder stringByAppendingPathComponent:@"XFDFTest-encrypted.xfdf"]];
    NSLog(@"Using XFDF file at %@", fileXML.path);

    // Create an example XFDF from the current document if one doesn't already exist.
    // [NSFileManager.defaultManager removeItemAtURL:fileXML error:NULL]; // DEBUG HELPER: delete existing file.
    if (![NSFileManager.defaultManager fileExistsAtPath:(NSString *)fileXML.path]) {
        // Collect all existing annotations from the document
        PSPDFDocument *tempDocument = [[PSPDFDocument alloc] initWithURL:documentURL];
        NSMutableArray *annotations = [NSMutableArray array];
        for (NSArray *pageAnnots in [tempDocument allAnnotationsOfType:PSPDFAnnotationTypeAll].allValues) {
            [annotations addObjectsFromArray:pageAnnots];
        }
        // Write the file
        NSError *error;
        id<PSPDFDataSink> dataSink = [[PSPDFAESCryptoDataSink alloc] initWithURL:fileXML passphraseProvider:passphraseProvider options:PSPDFDataSinkOptionNone];
        if (dataSink) {
            if (![[PSPDFXFDFWriter new] writeAnnotations:annotations toDataSink:dataSink documentProvider:tempDocument.documentProviders[0] error:&error]) {
                NSLog(@"Failed to write XFDF file: %@", error.localizedDescription);
            }
        } else {
            NSLog(@"Failed to open data sink: %@", error.localizedDescription);
        }
    }

    PSPDFAESCryptoDataProvider *cryptoDataProvider = [[PSPDFAESCryptoDataProvider alloc] initWithURL:fileXML passphraseProvider:passphraseProvider];
    if (!cryptoDataProvider) {
        NSLog(@"Error creating crypto data provider");
        return nil;
    }

    // Create document and set up the XFDF provider.
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;
    document.didCreateDocumentProviderBlock = ^(PSPDFDocumentProvider *documentProvider) {
        PSPDFXFDFAnnotationProvider *XFDFProvider = [[PSPDFXFDFAnnotationProvider alloc] initWithDocumentProvider:documentProvider dataProvider:cryptoDataProvider];
        // Note that if the document you're opening has form fields which you wish to be usable when using XFDF, you should also add the file annotation
        // provider to the annotation manager's `annotationProviders` array:
        //
        // PSPDFFileAnnotationProvider *fileProvider = documentProvider.annotationManager.fileAnnotationProvider;
        // documentProvider.annotationManager.annotationProviders = @[XFDFProvider, fileProvider];
        //
        documentProvider.annotationManager.annotationProviders = @[XFDFProvider];
    };

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end

@interface PSCXFDFAnnotationProviderEmbeddedExample : PSCExample
@end
@implementation PSCXFDFAnnotationProviderEmbeddedExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"XFDF Annotation Provider - Generate new file";
        self.contentDescription = @"Generating a new file with XFDF annotations using PSPDFProcessor";
        self.category = PSCExampleCategoryAnnotationProviders;
        self.priority = 90;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *documentURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];
    NSURL *outputURL = [samplesURL URLByAppendingPathComponent:@"OutputJKHFAsset.pdf"];

    // Load from an example XFDF file.
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSURL *fileXML = [NSURL fileURLWithPath:[docsFolder stringByAppendingPathComponent:@"XFDFTest.xfdf"]];
    NSLog(@"Using XFDF file at %@", fileXML.path);

    // Create document and set up the XFDF provider.
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.didCreateDocumentProviderBlock = ^(PSPDFDocumentProvider *documentProvider) {
        PSPDFXFDFAnnotationProvider *XFDFProvider = [[PSPDFXFDFAnnotationProvider alloc] initWithDocumentProvider:documentProvider fileURL:fileXML];
        // Note that if the document you're opening has form fields which you wish to be usable when using XFDF, you should also add the file annotation
        // provider to the annotation manager's `annotationProviders` array:
        //
        // PSPDFFileAnnotationProvider *fileProvider = documentProvider.annotationManager.fileAnnotationProvider;
        // documentProvider.annotationManager.annotationProviders = @[XFDFProvider, fileProvider];
        //
        documentProvider.annotationManager.annotationProviders = @[XFDFProvider];
    };

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain block:^(id sender) {
        // Generate a new document with embedded annotations
        PSPDFProcessorConfiguration *config = [[PSPDFProcessorConfiguration alloc] initWithDocument:document];
        [config modifyAnnotationsOfTypes:PSPDFAnnotationTypeAll change:PSPDFAnnotationChangeEmbed];

        PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:config securityOptions:nil];
        [processor writeToFileURL:outputURL error:nil];

        NSLog(@"Saved file to: %@", outputURL);
    }];
    controller.navigationItem.leftBarButtonItems = @[controller.closeButtonItem, saveButton];
    return controller;
}

@end

NS_ASSUME_NONNULL_END
