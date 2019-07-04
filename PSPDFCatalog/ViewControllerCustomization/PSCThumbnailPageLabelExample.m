//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCThumbnailsViewController : PSPDFViewController

@end
@interface PSCThumbnailGridViewCell : PSPDFThumbnailGridViewCell
@end

@interface PSCThumbnailPageLabelExample : PSCExample
@end
@implementation PSCThumbnailPageLabelExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Customize thumbnail page label";
        self.category = PSCExampleCategoryControllerCustomization;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSCThumbnailsViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

@implementation PSCThumbnailsViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:[configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {

                                               // Register our custom cell as subclass.
                                               [builder overrideClass:PSPDFThumbnailGridViewCell.class withClass:PSCThumbnailGridViewCell.class];
                                           }]];

    // Only use the PSCThumbnailGridViewCell subclass so that we don't override all examples here.
    // In your code you can simply use PSPDFThumbnailGridViewCell.
    [PSPDFRoundedLabel appearanceWhenContainedInInstancesOfClasses:@[PSCThumbnailGridViewCell.class]].rectColor = [UIColor colorWithRed:0.165 green:0.226 blue:0.650 alpha:0.800];
    [PSPDFRoundedLabel appearanceWhenContainedInInstancesOfClasses:@[PSCThumbnailGridViewCell.class]].cornerRadius = 20;
}

@end

@implementation PSCThumbnailGridViewCell

- (void)updatePageLabel {
    [super updatePageLabel];
    // You could set the pageLabel here as well, but UIAppearance is more elegant.
    // self.pageLabel.rectColor = [UIColor colorWithRed:0.068 green:0.092 blue:0.264 alpha:0.800];
}

@end
