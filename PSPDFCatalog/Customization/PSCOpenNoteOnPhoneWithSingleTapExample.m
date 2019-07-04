//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCOpenNoteOnPhoneWithSingleTapExample : PSCExample <PSPDFViewControllerDelegate>
@end
@implementation PSCOpenNoteOnPhoneWithSingleTapExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Open Note with single tap on iPhone";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.delegate = self;
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forAnnotations:(NSArray<PSPDFAnnotation *> *)annotations inRect:(CGRect)annotationRect onPageView:(PSPDFPageView *)pageView {
    // Modify the "Note..." menu item to auto-invoke.
    // Note: This is set to YES automatically on iPad.
    PSPDFAnnotation *firstAnnotation = annotations.firstObject;
    if (firstAnnotation.type == PSPDFAnnotationTypeNote && annotations.count == 1) {
        for (PSPDFMenuItem *menuItem in menuItems) {
            if ([menuItem.identifier isEqualToString:PSPDFAnnotationMenuNote]) {
                menuItem.shouldInvokeAutomatically = YES;
            }
        }
    }

    return menuItems;
}

@end
