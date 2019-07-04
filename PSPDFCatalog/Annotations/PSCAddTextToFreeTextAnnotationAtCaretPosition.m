//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCAddTextToFreeTextAnnotationAtCaretPosition : PSCExample
@property (nonatomic) PSPDFViewController *pdfController;
@end

@class PSCInsertTextViewController;
@protocol PSCInsertTextViewControllerDelegate <NSObject>

- (void)insertTextViewController:(PSCInsertTextViewController *)controller didSelectRowAtIndex:(NSUInteger)index;

@end

/// Custom subclass to add a button to the accessory view.
@interface PSCAddTextFreeTextAccessoryView : PSPDFFreeTextAccessoryView <PSCInsertTextViewControllerDelegate>
@property (nonatomic) PSPDFToolbarButton *insertTextButton;
@end

/// Custom controller that is displayed in the accessory view on button tap.
@interface PSCInsertTextViewController : PSPDFBaseTableViewController
@property (nonatomic, weak) id delegate;
@end

@implementation PSCAddTextToFreeTextAnnotationAtCaretPosition

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add FreeText annotation and insert text at caret position";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 100;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader temporaryDocumentWithString:@"Example Document"];

    // Add the annotation
    PSPDFFreeTextAnnotation *freeTextAnnotation = [[PSPDFFreeTextAnnotation alloc] init];
    freeTextAnnotation.color = UIColor.redColor;
    freeTextAnnotation.contents = @"This is a Free Text Annotation.";
    freeTextAnnotation.fontSize = 20.0;
    freeTextAnnotation.boundingBox = CGRectMake(200.0, 200.0, 200.0, 200.0);

    const NSUInteger targetPage = 0;
    freeTextAnnotation.pageIndex = targetPage;

    [freeTextAnnotation sizeToFit];
    [document addAnnotations:@[freeTextAnnotation] options:nil];

    // Create controller
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFFreeTextAccessoryView.class withClass:PSCAddTextFreeTextAccessoryView.class];
    }]];
    self.pdfController = controller;

    // Automate selection and entering edit mode
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Select annotation and get the view
        PSPDFPageView *pageView = [controller pageViewForPageAtIndex:controller.pageIndex];
        pageView.selectedAnnotations = @[freeTextAnnotation];
        PSPDFFreeTextAnnotationView *freeTextView = (PSPDFFreeTextAnnotationView *)[pageView annotationViewForAnnotation:freeTextAnnotation];

        // Begin editing and move caret somewhere to the front.
        [freeTextView beginEditing];
        freeTextView.textView.selectedRange = NSMakeRange(10, 0);
    });

    return controller;
}

@end

@implementation PSCAddTextFreeTextAccessoryView

- (PSPDFToolbarButton *)insertTextButton {
    if (!_insertTextButton) {
        _insertTextButton = [[PSPDFToolbarButton alloc] init];
        _insertTextButton.length = 50.0;
        _insertTextButton.accessibilityLabel = @"Insert Text";
        [_insertTextButton setTitle:@"Insert" forState:UIControlStateNormal];
        [_insertTextButton addTarget:self action:@selector(insertTextTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _insertTextButton;
}

- (void)insertTextTapped:(id)sender {
    // Second tap should dismiss the controller.
    if ([self dismissInsertTextViewControllerAnimated:YES]) return;

    // Present controller in a way that it's still a popover on iPhone.
    PSCInsertTextViewController *controller = [PSCInsertTextViewController new];
    controller.title = @"Example Insert Text Controller";
    controller.delegate = self;
    controller.modalPresentationStyle = UIModalPresentationPopover;
    NSDictionary *options = @{ PSPDFPresentationPopoverArrowDirectionsKey: @(UIPopoverArrowDirectionDown), PSPDFPresentationNonAdaptiveKey: @YES, PSPDFPresentationInNavigationControllerKey: @YES, PSPDFPresentationPopoverBackgroundColorKey: UIColor.whiteColor };

    [self.presentationContext.actionDelegate presentViewController:controller options:options animated:YES sender:sender completion:NULL];
}

- (BOOL)dismissInsertTextViewControllerAnimated:(BOOL)animated {
    return [self.presentationContext.actionDelegate dismissViewControllerOfClass:PSCInsertTextViewController.class animated:animated completion:NULL];
}

// Width changes should dismiss your popover, so ensure to add your hook here.
- (void)dismissPresentedViewControllersAnimated:(BOOL)animated {
    [super dismissPresentedViewControllersAnimated:animated];
    [self dismissInsertTextViewControllerAnimated:animated];
}

// Adds our custom button.
- (NSArray<__kindof PSPDFToolbarButton *> *)buttonsForWidth:(CGFloat)width {
    NSMutableArray<__kindof PSPDFToolbarButton *> *buttons = [[super buttonsForWidth:width] mutableCopy];

    // Insert button before "Clear".
    NSUInteger insertionIndex = [buttons indexOfObject:self.clearButton];
    if (insertionIndex == NSNotFound) {
        insertionIndex = buttons.count - 1;
    }
    [buttons insertObject:self.insertTextButton atIndex:insertionIndex];

    return [buttons copy];
}

- (void)insertTextViewController:(PSCInsertTextViewController *)controller didSelectRowAtIndex:(NSUInteger)index {
    // First dismiss the controller
    [controller dismissViewControllerAnimated:YES completion:NULL];

    // Note: This example was originally written to work from a bar button item from the controller context.
    // Since you are already in a free text accessory view, it would be easy to detect what annotation is selected here.
    // I've left the original code in there so one can see the original approach and also go for a simpler solution.

    // Get current page view
    PSPDFViewController *pdfController = self.presentationContext.pdfController;
    PSPDFPageView *pageView = [pdfController pageViewForPageAtIndex:pdfController.pageIndex];

    // Find the first free text annotation that is selected.
    PSPDFFreeTextAnnotation *freeTextAnnotation;
    for (PSPDFAnnotation *annotation in pageView.selectedAnnotations) {
        if ([annotation isKindOfClass:PSPDFFreeTextAnnotation.class]) {
            freeTextAnnotation = (PSPDFFreeTextAnnotation *)annotation;
            break;
        }
    }

    // Nothing to do if no annotation is selected.
    if (!freeTextAnnotation) return;

    // Get the view of the annotation
    PSPDFFreeTextAnnotationView *freeTextView = (PSPDFFreeTextAnnotationView *)[pageView annotationViewForAnnotation:freeTextAnnotation];

    // Get the text view and update text at the selected range.
    UITextView *textView = freeTextView.textView;
    UITextRange *selectedRange = textView.selectedTextRange;
    if (selectedRange) {
        NSString *text = [NSString stringWithFormat:@"--NEW TEXT AT CARET POSITION (text index %tu--", index];
        [textView replaceRange:selectedRange withText:text];
    }
}

@end

@implementation PSCInsertTextViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PSCInsertTextTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Insert Text %tu", indexPath.row];
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate insertTextViewController:self didSelectRowAtIndex:indexPath.row];
}

@end
