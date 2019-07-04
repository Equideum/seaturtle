//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCVertialScrubberBar : PSCExample
@end
@implementation PSCVertialScrubberBar

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Vertical Scrubber Bar";
        self.contentDescription = @"Uses a vertical scrubber bar at the right edge";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 11;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    return [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
        builder.scrubberBarType = PSPDFScrubberBarTypeVerticalRight;
        builder.pageMode = PSCIsIPad() ? PSPDFPageModeAutomatic : PSPDFPageModeDouble;
    }]];
}

@end
