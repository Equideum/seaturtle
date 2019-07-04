//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAppDelegate.h"
#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import "UIBarButtonItem+PSCBlockSupport.h"

static PSPDFViewController *PSPDFFormExampleInvokeWithFilename(NSString *filename) {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:(NSURL *)[samplesURL URLByAppendingPathComponent:filename]];
    return [[PSPDFViewController alloc] initWithDocument:document];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interactive digital signing process

@interface PSCFormInteractiveDigitalSigningExample : PSCExample
@end
@implementation PSCFormInteractiveDigitalSigningExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Digital signing process (password: test)";
        self.category = PSCExampleCategoryForms;
        self.priority = 20;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *resURL = NSBundle.mainBundle.resourceURL;
    NSURL *samplesURL = [resURL URLByAppendingPathComponent:@"Samples"];
    NSURL *p12URL = [samplesURL URLByAppendingPathComponent:@"JohnAppleseed.p12"];

    NSData *p12data = [NSData dataWithContentsOfURL:p12URL];
    PSPDFPKCS12 *p12 = [[PSPDFPKCS12 alloc] initWithData:p12data];
    if (p12) {
        PSPDFPKCS12Signer *p12signer = [[PSPDFPKCS12Signer alloc] initWithDisplayName:@"John Appleseed" PKCS12:p12];

        PSPDFSignatureManager *signatureManager = PSPDFKit.sharedInstance.signatureManager;
        [signatureManager clearRegisteredSigners];
        [signatureManager registerSigner:p12signer];
        [signatureManager clearTrustedCertificates];

        // Add certs to trust store for the signature validation process
        NSURL *certURL = [samplesURL URLByAppendingPathComponent:@"JohnAppleseed.p7c"];
        NSData *certData = [NSData dataWithContentsOfURL:certURL];

        NSError *error;
        NSArray *certificates = [PSPDFX509 certificatesFromPKCS7Data:certData error:&error];
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            for (PSPDFX509 *x509 in certificates) {
                [signatureManager addTrustedCertificate:x509];
            }
        }
    }

    NSURL *documentURL = [samplesURL URLByAppendingPathComponent:@"Form_example.pdf"];
    NSURL *newURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, YES);
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:newURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Automated digital signing process

@interface PSCFormDigitalSigningExample : PSCExample
@end
@implementation PSCFormDigitalSigningExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Automated digital signing process";
        self.category = PSCExampleCategoryForms;
        self.priority = 20;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *p12URL = [samplesURL URLByAppendingPathComponent:@"JohnAppleseed.p12"];

    NSData *p12data = [NSData dataWithContentsOfURL:p12URL];
    NSAssert(p12data, @"Error reading p12 data from %@", p12URL);
    PSPDFPKCS12 *p12 = [[PSPDFPKCS12 alloc] initWithData:p12data];
    PSPDFPKCS12Signer *signer = [[PSPDFPKCS12Signer alloc] initWithDisplayName:@"John Appleseed" PKCS12:p12];
    signer.reason = @"Contract agreement";
    PSPDFSignatureManager *signatureManager = PSPDFKit.sharedInstance.signatureManager;
    [signatureManager clearRegisteredSigners];
    [signatureManager registerSigner:signer];

    [signatureManager clearTrustedCertificates];

    // Add certs to trust store for the signature validation process
    NSURL *certURL = [samplesURL URLByAppendingPathComponent:@"JohnAppleseed.p7c"];
    NSData *certData = [NSData dataWithContentsOfURL:certURL];

    NSError *error;
    NSArray *certificates = [PSPDFX509 certificatesFromPKCS7Data:certData error:&error];
    NSAssert(error == nil, @"Error loading certificates - %@", error.localizedDescription);
    for (PSPDFX509 *x509 in certificates) {
        [signatureManager addTrustedCertificate:x509];
    }

    PSPDFDocument *unsignedDocument = [[PSPDFDocument alloc] initWithURL:(NSURL *)[samplesURL URLByAppendingPathComponent:@"Form_example.pdf"]];
    NSArray *annotations = [unsignedDocument annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeWidget];
    PSPDFSignatureFormElement *signatureFormElement;
    for (PSPDFAnnotation *annotation in annotations) {
        if ([annotation isKindOfClass:PSPDFSignatureFormElement.class]) {
            signatureFormElement = (PSPDFSignatureFormElement *)annotation;
            break;
        }
    }
    NSAssert(signatureFormElement, @"Cannot find the signature field");

    NSString *fileName = [NSString stringWithFormat:@"%@.pdf", NSUUID.UUID.UUIDString];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    __block PSPDFDocument *signedDocument;
    // sign the document
    [signer signFormElement:signatureFormElement usingPassword:@"test" writeTo:path appearance:nil biometricProperties:nil completion:^(BOOL success, PSPDFDocument *document, NSError *err) {
        signedDocument = document;
    }];
    NSAssert(signedDocument, @"Error signing document");
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:signedDocument];

    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Programmatic Form Filling

@interface PSCFormFillingExample : PSCExample
@end
@implementation PSCFormFillingExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Programmatic Form Filling";
        self.contentDescription = @"Automatically fills out all forms in code";
        self.category = PSCExampleCategoryForms;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:(NSURL *)[samplesURL URLByAppendingPathComponent:@"Form_example.pdf"]];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Get all form objects and fill them in.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray<PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeWidget];
        for (PSPDFFormElement *formElement in annotations) {
            [NSThread sleepForTimeInterval:0.8];

            // Always update the model on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([formElement isKindOfClass:PSPDFTextFieldFormElement.class]) {
                    formElement.contents = [NSString stringWithFormat:@"Test %@", formElement.fieldName];
                } else if ([formElement isKindOfClass:PSPDFButtonFormElement.class]) {
                    [(PSPDFButtonFormElement *)formElement toggleButtonSelectionState];
                }
            });
        }
    });

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

    // Add feature to save a copy of the PDF.
    UIBarButtonItem *saveCopy = [[UIBarButtonItem alloc] initWithTitle:@"Save Copy" style:UIBarButtonItemStylePlain block:^(id sender) {
        // Create a copy of the document
        NSURL *tempURL = PSCTempFileURLWithPathExtension([NSString stringWithFormat:@"copy_%@", document.fileURL.lastPathComponent], @"pdf");
        NSURL *documentURL = document.fileURL;
        if (!documentURL) return;

        [NSFileManager.defaultManager copyItemAtURL:documentURL toURL:tempURL error:NULL];
        PSPDFDocument *documentCopy = [[PSPDFDocument alloc] initWithURL:tempURL];

        // Transfer form values
        NSArray<PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeWidget];
        NSArray<PSPDFAnnotation *> *annotationsCopy = [documentCopy annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeWidget];
        NSAssert(annotations.count == annotationsCopy.count, @"This example is built to only fill forms - don't add/remove annotations.");

        [annotationsCopy enumerateObjectsUsingBlock:^(PSPDFAnnotation *formElement, NSUInteger idx, BOOL *stop) {
            ((PSPDFFormElement *)formElement).contents = ((PSPDFFormElement *)annotations[idx]).contents;
        }];

        [documentCopy saveWithOptions:nil error:nil];

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[NSString stringWithFormat:@"Document copy saved to %@", documentCopy.fileURL.path] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:NULL]];
        [pdfController presentViewController:alertController animated:YES completion:NULL];

    }];
    NSArray<UIBarButtonItem *> *items = @[pdfController.closeButtonItem, saveCopy];
    [pdfController.navigationItem setLeftBarButtonItems:items animated:NO];
    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interactive Form with a Digital Signature

@interface PSCFormDigitallySignedModifiedExample : PSCExample
@end
@implementation PSCFormDigitallySignedModifiedExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Example of an Interactive Form with a Digital Signature";
        self.category = PSCExampleCategoryForms;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    return PSPDFFormExampleInvokeWithFilename(@"Form_example_signed.pdf");
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Form with formatted text fields

@interface PSCFormWithFormatting : PSCExample
@end
@implementation PSCFormWithFormatting

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"PDF Form with formatted text fields";
        self.category = PSCExampleCategoryForms;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:@"Forms_formatted.pdf"];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Readonly Form

@interface PSCFormWithFormattingReadonly : PSCExample
@end
@implementation PSCFormWithFormattingReadonly

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Readonly Form";
        self.category = PSCExampleCategoryForms;
        self.priority = 51;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:@"Forms_formatted.pdf"];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        NSMutableSet *editableAnnotationTypes = [builder.editableAnnotationTypes mutableCopy];
        [editableAnnotationTypes removeObject:PSPDFAnnotationStringWidget];
        builder.editableAnnotationTypes = editableAnnotationTypes;
    }]];
    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Programmatically fill form and save

@interface PSCFormFillingAndSavingExample : PSCExample
@end
@implementation PSCFormFillingAndSavingExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Programmatically fill form and save";
        self.category = PSCExampleCategoryForms;
        self.priority = 150;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Get the example form and copy it to a writable location
    NSURL *fileURL = [NSURL psc_sampleURLWithName:@"Form_example.pdf"];
    NSURL *documentURL = PSCCopyFileURLToDocumentFolderAndOverride(fileURL, YES);

    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;

    for (PSPDFFormElement *formElement in document.formParser.forms) {
        if ([formElement isKindOfClass:PSPDFButtonFormElement.class]) {
            [(PSPDFButtonFormElement *)formElement select];
        } else if ([formElement isKindOfClass:PSPDFChoiceFormElement.class]) {
            ((PSPDFChoiceFormElement *)formElement).selectedIndices = [NSIndexSet indexSetWithIndex:1];
        } else if ([formElement isKindOfClass:PSPDFTextFieldFormElement.class]) {
            formElement.contents = @"Test";
        }
    }

    [document saveWithOptions:nil completionHandler:^(NSError *error, NSArray *savedAnnotations) {
        if (error) {
            NSLog(@"Error while saving: %@", error.localizedDescription);
        } else {
            NSLog(@"File saved correctly to %@", documentURL.path);
        }
    }];

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Programmatically fill form and save

@interface PSCFormCreationExample : PSCExample
@end
@implementation PSCFormCreationExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Programmatically create a text form field";
        self.category = PSCExampleCategoryForms;
        self.priority = 160;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Get the example form and copy it to a writable location
    NSURL *fileURL = [NSURL psc_sampleURLWithName:@"Form_example.pdf"];
    NSURL *documentURL = PSCCopyFileURLToDocumentFolderAndOverride(fileURL, YES);

    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;

    // Create a new text field form element.
    PSPDFTextFieldFormElement *textFieldFormElement = [[PSPDFTextFieldFormElement alloc] init];
    textFieldFormElement.boundingBox = CGRectMake(200.0, 100.0, 200.0, 20.0);
    textFieldFormElement.pageIndex = 0;

    // Insert a form field for the form element. It will automatically be added to the document.
    NSError *error;
    PSPDFTextFormField *textFormField = [PSPDFTextFormField insertedTextFieldWithFullyQualifiedName:@"name" documentProvider:document.documentProviders[0] formElement:textFieldFormElement error:&error];
    if (!textFormField) {
        NSLog(@"Error: %@", error.localizedDescription);
    }

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Programmatically create a push button form field with a custom image

@interface PSCPushButtonCreationExample : PSCExample
@end
@implementation PSCPushButtonCreationExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Programmatically create a push button form field with a custom image";
        self.category = PSCExampleCategoryForms;
        self.priority = 170;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Create a push button and position them in the document.
    NSURL *fileURL = [NSURL psc_sampleURLWithName:@"Form_example.pdf"];
    NSURL *documentURL = PSCCopyFileURLToDocumentFolderAndOverride(fileURL, YES);

    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Create a push button and position them in the document.
    PSPDFButtonFormElement *pushButtonFormElement = [[PSPDFButtonFormElement alloc] init];
    pushButtonFormElement.boundingBox = CGRectMake(20.0, 200.0, 100.0, 83.0);
    pushButtonFormElement.pageIndex = 0;

    // Add a URL action.
    pushButtonFormElement.action = [[PSPDFURLAction alloc] initWithURLString:@"http://pspdfkit.com"];

    // Create a new appearance characteristics and set its normal icon.
    PSPDFAppearanceCharacteristics *appearanceCharacteristics = [PSPDFAppearanceCharacteristics new];
    appearanceCharacteristics.normalIcon = [UIImage imageNamed:@"exampleimage.jpg"];
    pushButtonFormElement.appearanceCharacteristics = appearanceCharacteristics;

    // Insert a form field for the form element. It will automatically be added to the document.
    NSError *error;
    PSPDFButtonFormField *pushButtonFormField = [PSPDFButtonFormField insertedButtonFieldWithType:PSPDFFormFieldTypePushButton fullyQualifiedName:@"PushButton" documentProvider:document.documentProviders[0] formElements:@[pushButtonFormElement]  buttonValues:@[@"pushButtonFormElement"] error:&error];
    if (!pushButtonFormField) {
        NSLog(@"Error: %@", error.localizedDescription);
    }

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end
