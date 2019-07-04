//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'CreateNoteFromTextSelectionExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCreateNoteFromTextSelectionExample : PSCExample <PSPDFViewControllerDelegate>
@end

@implementation PSCCreateNoteFromTextSelectionExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Create Note from selected text";
        self.contentDescription = @"Adds a new menu item that will create a note at the selected position with the text contents.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 60;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Set up the document.
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.delegate = self;
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forSelectedText:(NSString *)selectedText inRect:(CGRect)textRect onPageView:(PSPDFPageView *)pageView {
    if (selectedText.length > 0) {
        PSPDFMenuItem *createNoteMenu = [[PSPDFMenuItem alloc] initWithTitle:@"Create Note" block:^{
            // Make sure to ask for the author name, if it's not yet set.
            [PSPDFUsernameHelper askForDefaultAnnotationUsernameIfNeeded:pdfController completionBlock:^(NSString *userName) {
                PSPDFNoteAnnotation *noteAnnotation = [PSPDFNoteAnnotation new];
                noteAnnotation.pageIndex = pdfController.pageIndex;
                noteAnnotation.boundingBox = CGRectMake(CGRectGetMaxX(textRect), textRect.origin.y, 32.0, 32.0);
                noteAnnotation.contents = selectedText;
                [pageView.presentationContext.document addAnnotations:@[noteAnnotation] options:nil];
                [pageView.selectionView discardSelectionAnimated:NO]; // clear text
                [pageView showNoteControllerForAnnotation:noteAnnotation animated:YES]; // show popover
            }];
        }];
        return [menuItems arrayByAddingObjectsFromArray:@[createNoteMenu]];
    } else {
        return menuItems;
    }
}

@end
