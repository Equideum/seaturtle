//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCSimpleDrawingPDFViewController : PSPDFViewController
@property (nonatomic) UIButton *drawButton;
@end

@interface PSCSimpleDrawingButtonExample : PSCExample
@end
@implementation PSCSimpleDrawingButtonExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Simple Drawing Button";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    PSCSimpleDrawingPDFViewController *pdfController = [[PSCSimpleDrawingPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

@implementation PSCSimpleDrawingPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up global draw button
    UIButton *drawButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [drawButton setTitle:@"Draw" forState:UIControlStateNormal];
    drawButton.tintColor = UIColor.blackColor;
    drawButton.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    drawButton.layer.cornerRadius = 5.0;
    [drawButton sizeToFit];
    [drawButton addTarget:self action:@selector(drawButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.drawButton = drawButton;
    [self.contentView addSubview:drawButton];
    [self updateDrawButtonAppearance];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.drawButton.center = self.view.center;
}

- (void)drawButtonPressed:(id)sender {
    [self.annotationStateManager toggleState:PSPDFAnnotationStringInk];
    self.annotationStateManager.drawColor = UIColor.yellowColor;
    [self updateDrawButtonAppearance];
}

- (void)updateDrawButtonAppearance {
    if ([self.annotationStateManager.state isEqualToString:PSPDFAnnotationStringInk]) {
        self.drawButton.backgroundColor = [UIColor colorWithRed:0.846 green:1.000 blue:0.871 alpha:1.000];
    } else {
        self.drawButton.backgroundColor = UIColor.greenColor;
    }
}

@end
