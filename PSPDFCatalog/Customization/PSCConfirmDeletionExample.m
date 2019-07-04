//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCConfirmDeletionExample : PSCExample <PSPDFViewControllerDelegate>
@end

@implementation PSCConfirmDeletionExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Confirm deletion of annotations";
        self.contentDescription = @"This should not be needed, as undo/redo works for deletion as well, yet this example exlains how to customize actions.";
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
    NSMutableArray *mutableMenuItems = [NSMutableArray arrayWithArray:menuItems];

    // Show only if we actually have annotations.
    // This delegate is also used for the create annotations menu, in that case annotation count would be zero and there's nothing to delete.
    if (annotations.count > 0) {
        // We search for the deletion menu. title is localized so we use the identifier.
        const NSUInteger deleteMenuIndex = [menuItems indexOfObjectPassingTest:^BOOL(PSPDFMenuItem *item, NSUInteger idx, BOOL *stop) {
            return [item.identifier isEqualToString:PSPDFAnnotationMenuRemove];
        }];

        // Delete is not available for all annotation types (e.g. form objects can't be deleted) so don't hard-core this.
        if (deleteMenuIndex != NSNotFound) {
            // Note: For correct localization, a custom localization dictionary should be used.
            // Some languages have more forms of pluralizatin than just english.
            // This is just a simplified example.
            NSString *title = annotations.count == 1 ? @"Delete annotation?" : [NSString stringWithFormat:@"Delete %tu annotations?", annotations.count];

            // If we found the delete menu, change the implementation.
            PSPDFMenuItem *deleteMenu = mutableMenuItems[deleteMenuIndex];
            dispatch_block_t const originalDeletionBlock = deleteMenu.actionBlock;
            // Menu items are saved in a global object and it's good style to make sure we don't retain things there.
            __weak PSPDFViewController *weakPDFController = pdfController;
            deleteMenu.actionBlock = ^{
                UIAlertController *deleteConfirmation = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [deleteConfirmation addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [deleteConfirmation addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                                        originalDeletionBlock();
                                    }]];
                deleteConfirmation.popoverPresentationController.sourceRect = rect;
                deleteConfirmation.popoverPresentationController.sourceView = pageView;
                [weakPDFController presentViewController:deleteConfirmation animated:YES completion:NULL];
            };
        }
    }

    return mutableMenuItems;
}

@end
