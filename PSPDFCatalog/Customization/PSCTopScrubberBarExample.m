//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCTopScrubberBarExample

@interface PSCCustomUserInterfaceView : PSPDFUserInterfaceView
@end
@interface PSCCustomScrubberBar : PSPDFScrubberBar
@end

@interface PSCTopScrubberBarExample : PSCExample
@end
@implementation PSCTopScrubberBarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Top Scrubber Bar";
        self.contentDescription = @"Shows how to change the scrubber bar frame.";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 400;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    [PSCCustomUserInterfaceView appearance].pageLabelInsets = UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0);

    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFUserInterfaceView.class withClass:PSCCustomUserInterfaceView.class];
        // There's no need for actually overriding the scrubber bar in this example - it's just for testing.
        [builder overrideClass:PSPDFScrubberBar.class withClass:PSCCustomScrubberBar.class];
    }]];
    return pdfController;
}

@end

@implementation PSCCustomUserInterfaceView

- (void)updateScrubberBarFrameAnimated:(BOOL)animated {
    // Stick scrubber bar to the top.
    CGRect newFrame = self.dataSource.contentRect;
    newFrame.size.height = 60.0;
    self.scrubberBar.frame = newFrame;
}

@end

@implementation PSCCustomScrubberBar

- (instancetype)init {
    if ((self = [super init])) {
        NSLog(@"Using custom subclass");
    }
    return self;
}

@end
