//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCCustomProtocolLinkExample : PSCExample
@end
@implementation PSCCustomProtocolLinkExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Link Protocol";
        self.contentDescription = @"Uses a custom pspdfcatalog:// link protocol.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 800;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader temporaryDocumentWithString:@"Test PDF for custom protocols"];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Add link
    // By default, PSPDFKit would ask if you want to leave the app when an external URL is detected.
    // We skip this question if the protocol is defined within our own app.
    PSPDFLinkAnnotation *link = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfcatalog://this-is-a-test-link"]];
    CGSize pageSize = [document pageInfoForPageAtIndex:0].size;
    CGSize size = CGSizeMake(400, 300);
    link.boundingBox = CGRectMake((pageSize.width - size.width) / 2.0, (pageSize.height - size.height) / 2.0, size.width, size.height);
    [document addAnnotations:@[link] options:nil];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

NS_ASSUME_NONNULL_END
