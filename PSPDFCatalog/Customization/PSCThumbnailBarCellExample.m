//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomThumbnailCell : PSPDFThumbnailGridViewCell
@end
@implementation PSCCustomThumbnailCell

- (void)updatePageLabel {
    [super updatePageLabel];

    // Set to top centered.
    self.pageLabel.frame = CGRectMake(10.0, 10.0, self.frame.size.width - 20., self.pageLabel.frame.size.height);
}

@end

@interface PSCThumbnailBarCellExample : PSCExample
@end
@implementation PSCThumbnailBarCellExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Thumbnail Bar Cells";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 100;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.thumbnailBarMode = PSPDFThumbnailBarModeScrollable;
        [builder overrideClass:PSPDFThumbnailGridViewCell.class withClass:PSCCustomThumbnailCell.class];
    }]];
    pdfController.userInterfaceView.thumbnailBar.showPageLabels = YES;
    return pdfController;
}

@end
