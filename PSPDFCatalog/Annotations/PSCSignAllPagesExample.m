//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import <objc/runtime.h>
#import <tgmath.h>
#import <PSPDFKit/PSPDFProcessor.h>

static const char PSCSignatureCompletionBlock;

@interface PSCSignAllPagesExample : PSCExample <PSPDFSignatureViewControllerDelegate, PSPDFProcessorDelegate>
@property (nonatomic, strong) PSPDFStatusHUDItem *status;
@end

@implementation PSCSignAllPagesExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Sign All Pages";
        self.contentDescription = @"Will add a signature (ink annotation) to all pages of a document, optionally flattened.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 200;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    UIViewController *baseViewController = delegate.currentViewController;
    if (!baseViewController) {
        return nil;
    }

    // Ask for the annotation username, if needed.
    if (!PSPDFUsernameHelper.isDefaultAnnotationUserNameSet) {
        // We don't use the static helper here because we do not yet have a PSPDFViewController at this point.
        PSPDFUsernameHelper *helper = [PSPDFUsernameHelper new];
        [helper askForDefaultAnnotationUsername:baseViewController suggestedName:nil completionBlock:^(NSString *userName) {
            [self showSignatureUIOnViewController:baseViewController];
        }];
    } else {
        [self showSignatureUIOnViewController:baseViewController];
    }

    return nil;
}

- (void)showSignatureUIOnViewController:(UIViewController *)baseViewController {
    // Show the signature controller
    PSPDFSignatureViewController *signatureController = [[PSPDFSignatureViewController alloc] init];
    signatureController.naturalDrawingEnabled = YES;
    signatureController.delegate = self;
    UINavigationController *signatureContainer = [[UINavigationController alloc] initWithRootViewController:signatureController];
    [baseViewController presentViewController:signatureContainer animated:YES completion:NULL];

    // To make the example more concise, we're using a callback block here.
    void (^signatureCompletionBlock)(PSPDFSignatureViewController *theSignatureController) = ^(PSPDFSignatureViewController *theSignatureController) {
        // Create the document.
        PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
        document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled; // Don't pollute other examples.

        // We want to add signture at the bottom of the page.
        for (NSUInteger pageIndex = 0; pageIndex < document.pageCount; pageIndex++) {
            // Check if we're already signed and ignore.
            BOOL alreadySigned = NO;
            NSArray<PSPDFAnnotation *> *annotationsForPage = [document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeInk];
            for (PSPDFInkAnnotation *ann in annotationsForPage) {
                if ([ann.name isEqualToString:@"Signature"]) {
                    alreadySigned = YES;
                    break;
                }
            }

            // Not yet signed -> create new Ink annotation.
            if (!alreadySigned) {
                const CGFloat margin = 10.0;
                const CGSize maxSize = CGSizeMake(150.0, 75.0);

                // Prepare the lines and convert them from view space to PDF space. (PDF space is mirrored!)
                PSPDFPageInfo *pageInfo = [document pageInfoForPageAtIndex:pageIndex];
                NSArray *lines = PSPDFConvertViewLinesToPDFLines(signatureController.lines, pageInfo, (CGRect){.size = pageInfo.size});

                // Calculate the size, aspect ratio correct.
                CGSize annotationSize = PSPDFBoundingBoxFromLines(lines, 2).size;
                CGFloat scale = PSCScaleForSizeWithinSize(annotationSize, maxSize);
                annotationSize = CGSizeMake(lround(annotationSize.width * scale), lround(annotationSize.height * scale));

                // Create the annotation.
                PSPDFInkAnnotation *annotation = [[PSPDFInkAnnotation alloc] initWithLines:lines];
                annotation.name = @"Signature"; // Arbitrary string, will be persisted in the PDF.
                annotation.lineWidth = 3.0;
                // Add lines to bottom right. (PDF zero is bottom left)
                annotation.boundingBox = CGRectMake(pageInfo.size.width - annotationSize.width - margin, margin, annotationSize.width, annotationSize.height);
                annotation.color = signatureController.drawView.strokeColor;
                annotation.naturalDrawingEnabled = signatureController.naturalDrawingEnabled;
                annotation.contents = [NSString stringWithFormat:@"Signed on %@ by test user.", [NSDateFormatter localizedStringFromDate:NSDate.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle]];
                annotation.pageIndex = pageIndex;

                // Add annotation.
                [document addAnnotations:@[annotation] options:nil];
            }
        }

        // Now we could flatten the PDF so that the signature is "burned in".
        UIAlertController *flattenAlert = [UIAlertController alertControllerWithTitle:@"Flatten Annotations" message:@"Flattening will merge the annotations with the page content" preferredStyle:UIAlertControllerStyleAlert];
        [flattenAlert addAction:[UIAlertAction actionWithTitle:@"Flatten" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                          NSURL *tempURL = PSCTempFileURLWithPathExtension(@"flattened_signaturetest", @"pdf");
                          self.status = [PSPDFStatusHUDItem progressWithText:[PSPDFLocalize(@"Preparing") stringByAppendingString:@"…"]];
                          [self.status pushAnimated:YES completion:NULL];
                          // Perform in background to allow progress showing.
                          dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                              PSPDFProcessorConfiguration *configuration = [[PSPDFProcessorConfiguration alloc] initWithDocument:document];
                              [configuration modifyAnnotationsOfTypes:PSPDFAnnotationTypeAll change:PSPDFAnnotationChangeFlatten];

                              PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:configuration securityOptions:nil];
                              processor.delegate = self;
                              [processor writeToFileURL:tempURL error:NULL];

                              // completion
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.status popAnimated:YES completion:NULL];
                                  PSPDFDocument *flattenedDocument = [[PSPDFDocument alloc] initWithURL:tempURL];
                                  PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:flattenedDocument];
                                  [baseViewController.navigationController pushViewController:pdfController animated:YES];
                              });
                          });
                      }]];
        [flattenAlert addAction:[UIAlertAction actionWithTitle:@"Allow Editing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                          PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
                          [baseViewController.navigationController pushViewController:pdfController animated:YES];
                      }]];
        [baseViewController presentViewController:flattenAlert animated:YES completion:NULL];
    };

    objc_setAssociatedObject(signatureController, &PSCSignatureCompletionBlock, signatureCompletionBlock, OBJC_ASSOCIATION_COPY);
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFSignatureViewControllerDelegate

// Sign all pages example
- (void)signatureViewControllerDidFinish:(PSPDFSignatureViewController *)signatureController withSigner:(nullable PSPDFSigner *)signer shouldSaveSignature:(BOOL)shouldSaveSignature {
    [signatureController dismissViewControllerAnimated:YES completion:^{
        // Load and execute completion block
        void (^signatureCompletionBlock)(PSPDFSignatureViewController *signatureController) = objc_getAssociatedObject(signatureController, &PSCSignatureCompletionBlock);
        if (signatureCompletionBlock) signatureCompletionBlock(signatureController);
    }];
}

- (void)signatureViewControllerDidCancel:(PSPDFSignatureViewController *)signatureController {
    [signatureController dismissViewControllerAnimated:YES completion:NULL];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFProcessorDelegate

- (void)processor:(PSPDFProcessor *)processor didProcessPage:(NSUInteger)currentPage totalPages:(NSUInteger)totalPages {
    self.status.progress = (currentPage + 1) / (float)totalPages;
}

@end
