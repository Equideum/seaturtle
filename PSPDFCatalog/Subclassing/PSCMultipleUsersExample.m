//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

// Allows multiple annotation sets (e.g. different users)
@interface PSCMultipleUsersPDFViewController : PSPDFViewController
@end

@interface PSCMultipleUsersExample : PSCExample
@end
@implementation PSCMultipleUsersExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Multiple annotation sets / user switch";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *controller = [[PSCMultipleUsersPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end

@interface PSCMultipleUsersPDFViewController ()
@property (nonatomic, copy) NSString *currentUsername;
@end

@implementation PSCMultipleUsersPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:configuration];

    // Set a demo user.
    self.currentUsername = @"Testuser";

    // Updates the path at the right time.
    __weak typeof(self) weakSelf = self;
    document.didCreateDocumentProviderBlock = ^(PSPDFDocumentProvider *documentProvider) {
        NSURL *dataURL = [NSURL fileURLWithPath:(NSString *)documentProvider.document.dataDirectory];
        __auto_type fileURL = [dataURL URLByAppendingPathComponent:[NSString stringWithFormat:@"annotations_%@.pspdfkit", weakSelf.currentUsername]];
        __auto_type fileAnnotationProvider = [[PSPDFFileAnnotationProvider alloc] initWithDocumentProvider:documentProvider fileURL:fileURL];
        documentProvider.annotationManager.annotationProviders = @[fileAnnotationProvider];
    };

    // This example will only work for external file save mode.
    document.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;

    // Set custom toolbar button.
    [self updateCustomToolbar];
    self.documentInfoCoordinator.availableControllerOptions = @[PSPDFDocumentInfoOptionAnnotations];
    self.navigationItem.rightBarButtonItems = @[self.thumbnailsButtonItem, self.outlineButtonItem, self.annotationButtonItem];
}

- (void)setCurrentUsername:(NSString *)currentUsername {
    if (currentUsername != _currentUsername) {
        _currentUsername = [currentUsername copy];
        // Forward to the document
        self.document.defaultAnnotationUsername = currentUsername;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)updateCustomToolbar {
    UIBarButtonItem *switchUserButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"User: %@", self.currentUsername] style:UIBarButtonItemStylePlain target:self action:@selector(switchUser)];
    self.navigationItem.leftBarButtonItems = @[self.closeButtonItem, switchUserButtonItem];
}

// This could be a lot sexier - e.g. showing all available users in a nice table with edit/delete all etc.
- (void)switchUser {
    // Dismiss any popovers. iOS 8 doesn't like presenting alerts next to them.
    [self dismissViewControllerOfClass:Nil animated:YES completion:NULL];

    // Save existing documents.
    [self.document saveWithOptions:nil error:nil];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Switch user" message:@"Enter username." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = self.currentUsername;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    __weak UIAlertController *weakAlertController = alertController;
    [alertController addAction:[UIAlertAction actionWithTitle:@"Switch" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                         // TODO: In a real application you want to make the username unique and also check for characters that are trouble on file systems.
                         NSString *username = weakAlertController.textFields.firstObject.text ?: @"";

                         // Set new username
                         self.currentUsername = username;

                         // Then clear the document cache (forces document provider regeneration)
                         [self.document clearCache];
                         // Update toolbar to show new name.
                         [self updateCustomToolbar];
                         // And finally - redraw the PDF.
                         [self reloadData];
                     }]];
    [self presentViewController:alertController animated:YES completion:NULL];
}

@end
