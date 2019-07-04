//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomDocumentInfoCoordinator : PSPDFDocumentInfoCoordinator
@end
@interface PSCCustomOutlineViewController : UIViewController<PSPDFSegmentImageProviding>
@end

@interface PSCCustomOutlineControllerExample : PSCExample
@end
@implementation PSCCustomOutlineControllerExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Outline Controller";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 100;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFDocumentInfoCoordinator.class withClass:PSCCustomDocumentInfoCoordinator.class];
    }]];
    return pdfController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCCustomOutlineBarButtonItem

@implementation PSCCustomDocumentInfoCoordinator

- (UIViewController *)controllerForOption:(PSPDFDocumentInfoOption)option {
    UIViewController *viewController;

    if ([option isEqualToString:PSPDFDocumentInfoOptionOutline]) {
        viewController = [[PSCCustomOutlineViewController alloc] init];
    } else {
        viewController = [super controllerForOption:option];
    }
    return viewController;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCCustomOutlineViewController

@implementation PSCCustomOutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.yellowColor;

    UILabel *customLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    customLabel.translatesAutoresizingMaskIntoConstraints = NO;
    customLabel.text = @"I am a custom outline controller";
    customLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:customLabel];

    [NSLayoutConstraint activateConstraints:
     @[
       [customLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20.],
       [customLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20.],
       [customLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
       [customLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
       ]];

    [customLabel sizeToFit];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFSegmentImageProviding

- (nullable UIImage *)segmentImage {
    UIImage *image = [PSPDFKit imageNamed:@"x"];
    return image;
}

@end
