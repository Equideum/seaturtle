//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "NSObject+PSCDeallocationBlock.h"
#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomizeAnnotationToolbarExample : PSCExample <PSPDFViewControllerDelegate>
@end
@interface PSCCustomizedAnnotationToolbar : PSPDFAnnotationToolbar
@end

@implementation PSCCustomizeAnnotationToolbarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Customized Annotation Toolbar";
        self.contentDescription = @"Customizes the buttons in the annotation toolbar.";
        self.category = PSCExampleCategoryBarButtons;
        self.priority = 200;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        // Register the class overrides.
        [builder overrideClass:PSPDFAnnotationToolbar.class withClass:PSCCustomizedAnnotationToolbar.class];
    }]];
    pdfController.delegate = self;

    return pdfController;
}

@end

@implementation PSCCustomizedAnnotationToolbar

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
        PSPDFAnnotationGroupItem *highlight = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringHighlight];
        PSPDFAnnotationGroupItem *underline = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringUnderline];

        PSPDFAnnotationGroupItem *freeText = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringFreeText];

        PSPDFAnnotationGroupItem *note = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringNote];

        PSPDFAnnotationGroupItem *square = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringSquare];
        PSPDFAnnotationGroupItem *circle = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringCircle];
        PSPDFAnnotationGroupItem *line = [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringLine];

        NSArray<PSPDFAnnotationGroup *> *compactGroups = @[[PSPDFAnnotationGroup groupWithItems:@[highlight, underline, freeText, note]], [PSPDFAnnotationGroup groupWithItems:@[square, circle, line]]];
        PSPDFAnnotationToolbarConfiguration *compact = [[PSPDFAnnotationToolbarConfiguration alloc] initWithAnnotationGroups:compactGroups];

        NSArray<PSPDFAnnotationGroup *> *regularGroups = @[[PSPDFAnnotationGroup groupWithItems:@[highlight, underline]], [PSPDFAnnotationGroup groupWithItems:@[freeText]], [PSPDFAnnotationGroup groupWithItems:@[note]], [PSPDFAnnotationGroup groupWithItems:@[square, circle, line]]];
        PSPDFAnnotationToolbarConfiguration *regular = [[PSPDFAnnotationToolbarConfiguration alloc] initWithAnnotationGroups:regularGroups];

        self.configurations = @[compact, regular];
    }
    return self;
}

@end
