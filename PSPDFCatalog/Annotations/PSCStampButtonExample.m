//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'StampButtonExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCStampButtonExample : PSCExample <PSPDFViewControllerDelegate>
@end
@implementation PSCStampButtonExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Stamp Annotation Button";
        self.contentDescription = @"Uses a stamp annotation as button.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 130;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    PSPDFStampAnnotation *imageStamp = [[PSPDFStampAnnotation alloc] init];
    imageStamp.image = [UIImage imageNamed:@"exampleimage.jpg"];
    imageStamp.boundingBox = CGRectMake(100.0, 100.0, imageStamp.image.size.width / 4., imageStamp.image.size.height / 4.);

    imageStamp.pageIndex = 0;

    // We need to define an action to get a highlight.
    // You can also use an empty script and do custom processing in the didTapOnAnnotation: delegate.
    imageStamp.additionalActions = @{ @(PSPDFAnnotationTriggerEventMouseUp): [[PSPDFJavaScriptAction alloc] initWithScript:@"app.alert(\"Hello, it's me. I was wondering...\");"] };

    [document addAnnotations:@[imageStamp] options:nil];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.delegate = self;
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (BOOL)pdfViewController:(PSPDFViewController *)pdfController didTapOnAnnotation:(PSPDFAnnotation *)annotation annotationPoint:(CGPoint)annotationPoint annotationView:(UIView<PSPDFAnnotationPresenting> *)annotationView pageView:(PSPDFPageView *)pageView viewPoint:(CGPoint)viewPoint {
    // Alternatively, you can use this delegate to perform custom hook.s

    return NO;
}

@end
