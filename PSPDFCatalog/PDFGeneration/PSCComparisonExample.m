//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'ComparisonExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCComparisonExample : PSCExample
@end
@implementation PSCComparisonExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Document Comparison";
        self.contentDescription = @"Compare PDFs by using a different stroke color for each document.";
        self.category = PSCExampleCategoryDocumentGeneration;
        self.priority = 5;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *firstDocument = [PSCAssetLoader documentWithName:@"FloorPlan_1.pdf"];
    PSPDFDocument *secondDocument = [PSCAssetLoader documentWithName:@"FloorPlan_2.pdf"];

    PSPDFTabbedViewController *tabbedController = [[PSPDFTabbedViewController alloc] init];
    tabbedController.documents = [self generateComparisonDocumentsByMergingDocument:firstDocument withDocument:secondDocument];
    [tabbedController setVisibleDocument:tabbedController.documents[2] scrollToPosition:NO animated:NO];
    return tabbedController;
}

- (NSArray<PSPDFDocument *> *)generateComparisonDocumentsByMergingDocument:(PSPDFDocument *)firstDocument withDocument:(PSPDFDocument *)secondDocument {
    PSPDFDocument *greenDocument = [self createNewPDFFromDocument:firstDocument withStrokeColor:UIColor.greenColor fileName:@"Old.pdf"];
    PSPDFDocument *redDocument = [self createNewPDFFromDocument:secondDocument withStrokeColor:UIColor.redColor fileName:@"New.pdf"];

    PSPDFProcessorConfiguration *configuration = [[PSPDFProcessorConfiguration alloc] initWithDocument:greenDocument];
    [configuration mergePageFromDocument:redDocument password:nil sourcePageIndex:0 destinationPageIndex:0 transform:CGAffineTransformIdentity blendMode:kCGBlendModeDarken];

    PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:configuration securityOptions:nil];
    NSURL *mergedDocumentURL = [PSCComparisonExample temporaryURLWithName:@"Comparison.pdf"];
    [processor writeToFileURL:mergedDocumentURL];

    PSPDFDocument *mergedDocument = [[PSPDFDocument alloc] initWithURL:mergedDocumentURL];
    return @[greenDocument, redDocument, mergedDocument];
}

- (PSPDFDocument *)createNewPDFFromDocument:(PSPDFDocument *)document withStrokeColor:(UIColor *)strokeColor fileName:(NSString *)fileName {
    PSPDFProcessorConfiguration *configuration = [[PSPDFProcessorConfiguration alloc] initWithDocument:document];
    [configuration changeStrokeColorOnPageAtIndex:0 toColor:strokeColor];

    PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:configuration securityOptions:nil];
    NSURL *destinationURL = [PSCComparisonExample temporaryURLWithName:fileName];
    [processor writeToFileURL:destinationURL];
    return [[PSPDFDocument alloc] initWithURL:destinationURL];
}

+ (NSURL *)temporaryURLWithName:(NSString *)name {
    return [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:name];
}

@end
