//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//


#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"

@interface PSCDisableRenameBookmarkCell : PSPDFBookmarkCell
@end

@interface PSCDisableBookmarkRenameExample : PSCExample
@end

@implementation PSCDisableBookmarkRenameExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Disable Bookmark Rename";
        self.contentDescription = @"Shows how to use a custom bookmark cell and disable bookmark editing";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 250;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *sourceURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameQuickStart];
    NSURL *writableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, NO);
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:writableURL];

    PSPDFConfiguration *configuration = [PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        // Use our PSPDFBookmarkCell subclass which has disabled bookmark editing.
        [builder overrideClass:PSPDFBookmarkCell.class withClass:PSCDisableRenameBookmarkCell.class];
    }];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];
    [controller.navigationItem setRightBarButtonItems:@[controller.outlineButtonItem, controller.bookmarkButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];

    return controller;
}

@end

@implementation PSCDisableRenameBookmarkCell

/// Overriding this method and returning false disables the bookmark name editing when the cell is in edit mode.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}

@end
