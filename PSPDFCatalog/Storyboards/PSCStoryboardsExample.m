//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCExample.h"

@interface PSCStoryboardTableViewController : UITableViewController
@end

@interface PSCStoryboardsInitWithStoryboardExample : PSCExample
@end
@implementation PSCStoryboardsInitWithStoryboardExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Init with Storyboard";
        self.category = PSCExampleCategoryStoryboards;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateInitialViewController];
    return controller;
}

@end

@implementation PSCStoryboardTableViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.cellLayoutMarginsFollowReadableWidth = YES;
}

// We don't have enough semantics to tell with just IB that we do want to use the content of the table cells, so we add some additional logic.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // only apply this if our destination is a PSPDFViewController.
    if ([segue.destinationViewController isKindOfClass:PSPDFViewController.class]) {
        PSPDFViewController *pdfController = (PSPDFViewController *)segue.destinationViewController;

        if ([sender isKindOfClass:UITableViewCell.class]) {
            UITableViewCell *cell = (UITableViewCell *)sender;

            // ideally, you would do it like this:
             NSString *pdfPath = [[NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"Samples"] stringByAppendingPathComponent:(NSString *)cell.textLabel.text];
             pdfController.document = [[PSPDFDocument alloc] initWithURL:[NSURL fileURLWithPath:pdfPath]];
        }
    }
}

@end
