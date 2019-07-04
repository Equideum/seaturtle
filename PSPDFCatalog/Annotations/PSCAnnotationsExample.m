//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'AnnotationsExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsCustomAnnotationsWithMultipleFilesExample

@interface PSCAnnotationsCustomAnnotationsWithMultipleFilesExample : PSCExample
@end
@implementation PSCAnnotationsCustomAnnotationsWithMultipleFilesExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom annotations with multiple files";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 400;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSMutableArray<PSPDFCoordinatedFileDataProvider *> *dataProviders = [NSMutableArray array];
    for (NSString *filename in @[@"A", @"B", @"C", @"D"]) {
        [dataProviders addObject:[[PSPDFCoordinatedFileDataProvider alloc] initWithFileURL:(NSURL *)[NSBundle.mainBundle URLForResource:filename withExtension:@"pdf" subdirectory:@"Samples"]]];
    }
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:dataProviders];

    // We're lazy here. 2 = UIViewContentModeScaleAspectFill
    PSPDFLinkAnnotation *aVideo = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://[contentMode=2]localhost/Bundle/big_buck_bunny.mp4"]];
    aVideo.boundingBox = (CGRect){.size = [document pageInfoForPageAtIndex:5].size};
    aVideo.pageIndex = 5;
    [document addAnnotations:@[aVideo] options:nil];

    PSPDFLinkAnnotation *anImage = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://[contentMode=2]localhost/Bundle/exampleImage.jpg"]];
    anImage.boundingBox = (CGRect){.size = [document pageInfoForPageAtIndex:2].size};
    anImage.pageIndex = 2;
    [document addAnnotations:@[anImage] options:nil];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsAnnotationLinkstoExternalDocumentsExample

@interface PSCAnnotationsAnnotationLinkstoExternalDocumentsExample : PSCExample
@end
@implementation PSCAnnotationsAnnotationLinkstoExternalDocumentsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Annotation Links to external documents";
        self.contentDescription = @"PDF links can point to pages within the same document, or also different documents or websites.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 600;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:@"one.pdf"];
    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsXFDFWritingExample

@interface PSCAnnotationsXFDFWritingExample : PSCExample
@end
@implementation PSCAnnotationsXFDFWritingExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"XFDF Writing";
        self.contentDescription = @"Custom code that creates annotations in code and exports them as XFDF.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 900;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *documentURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameQuickStart];

    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *fileXML = [NSURL fileURLWithPath:[docsFolder stringByAppendingPathComponent:@"XFDFTest.xfdf"]];
    NSLog(@"fileXML: %@", fileXML);

    // Collect all existing annotations from the document
    PSPDFDocument *tempDocument = [[PSPDFDocument alloc] initWithURL:documentURL];
    NSMutableArray *annotations = [NSMutableArray array];

    PSPDFLinkAnnotation *linkAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"https://pspdfkit.com"]];
    linkAnnotation.boundingBox = CGRectMake(100.0, 80.0, 200.0, 300.0);
    linkAnnotation.pageIndex = 1;
    [annotations addObject:linkAnnotation];

    PSPDFLinkAnnotation *aStream = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]];
    aStream.boundingBox = CGRectMake(100.0, 100.0, 200.0, 300.0);
    aStream.pageIndex = 0;
    [annotations addObject:aStream];

    PSPDFLinkAnnotation *anImage = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://ramitia.files.wordpress.com/2011/05/durian1.jpg"]];
    anImage.boundingBox = CGRectMake(100.0, 100.0, 200.0, 300.0);
    anImage.pageIndex = 3;
    [annotations addObject:anImage];

    PSPDFLinkAnnotation *aVideo2 = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://[autostart:true]localhost/Bundle/big_buck_bunny.mp4"]];
    aVideo2.boundingBox = CGRectMake(100.0, 100.0, 200.0, 300.0);
    aVideo2.pageIndex = 2;
    [annotations addObject:aVideo2];

    PSPDFLinkAnnotation *anImage3 = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:[NSString stringWithFormat:@"pspdfkit://[contentMode=%ld]ramitia.files.wordpress.com/2011/05/durian1.jpg", (long)UIViewContentModeScaleAspectFill]]];
    anImage3.linkType = PSPDFLinkAnnotationImage;
    anImage3.boundingBox = CGRectMake(100.0, 100.0, 200.0, 300.0);
    anImage3.pageIndex = 4;
    [annotations addObject:anImage3];

    NSLog(@"annotations: %@", annotations);

    // Write the file
    NSError *error;
    PSPDFFileDataSink *dataSink = [[PSPDFFileDataSink alloc] initWithFileURL:fileXML options:PSPDFDataSinkOptionNone error:&error];
    if (!dataSink) {
        NSLog(@"Error opening data sink: %@", error.localizedDescription);
        return nil;
    }

    if (![[PSPDFXFDFWriter new] writeAnnotations:annotations toDataSink:dataSink documentProvider:tempDocument.documentProviders[0] error:&error]) {
        NSLog(@"Failed to write XFDF file: %@", error.localizedDescription);
    }

    // Create document and set up the XFDF provider
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:documentURL];
    document.didCreateDocumentProviderBlock = ^(PSPDFDocumentProvider *documentProvider) {
        PSPDFXFDFAnnotationProvider *XFDFProvider = [[PSPDFXFDFAnnotationProvider alloc] initWithDocumentProvider:documentProvider fileURL:fileXML];
        documentProvider.annotationManager.annotationProviders = @[XFDFProvider];
    };

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end
