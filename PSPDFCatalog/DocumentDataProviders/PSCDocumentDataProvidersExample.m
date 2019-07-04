//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCDocumentDataProvidersNSURLExample

@interface PSCDocumentDataProvidersNSURLExample : PSCExample
@end
@implementation PSCDocumentDataProvidersNSURLExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"NSURL";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.printButtonItem, controller.emailButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCDocumentDataProvidersNSDataExample

@interface PSCDocumentDataProvidersNSDataExample : PSCExample
@end
@implementation PSCDocumentDataProvidersNSDataExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"NSData";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 20;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *assetURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    NSData *data = [NSData dataWithContentsOfURL:assetURL options:NSDataReadingMappedIfSafe error:NULL];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[[[PSPDFDataContainerProvider alloc] initWithData:data]]];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.activityButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCSingleDataProviderExample

@interface PSCSingleDataProviderExample : PSCExample
@end
@implementation PSCSingleDataProviderExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Single data provider";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *assetURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    NSData *data = [NSData dataWithContentsOfURL:assetURL options:NSDataReadingMappedIfSafe error:NULL];
    id<PSPDFDataProviding> dataProvider = [[PSPDFDataContainerProvider alloc] initWithData:data];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[dataProvider]];
    document.title = @"PSPDFDataProviding PDF";
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.emailButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCMultipleDataProvidersExample

@interface PSCMultipleDataProvidersExample : PSCExample
@end
@implementation PSCMultipleDataProvidersExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Multiple data providers";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *assetURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    NSData *data = [NSData dataWithContentsOfURL:assetURL options:NSDataReadingMappedIfSafe error:NULL];
    PSPDFDataContainerProvider *dataProvider1 = [[PSPDFDataContainerProvider alloc] initWithData:data];
    PSPDFDataContainerProvider *dataProvider2 = [[PSPDFDataContainerProvider alloc] initWithData:data];
    PSPDFDataContainerProvider *dataProvider3 = [[PSPDFDataContainerProvider alloc] initWithData:data];
    PSPDFDataContainerProvider *dataProvider4 = [[PSPDFDataContainerProvider alloc] initWithData:data];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[dataProvider1, dataProvider2, dataProvider3, dataProvider4]];
    document.title = @"PSPDFDataContainerProvider PDF";
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.activityButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCDocumentDataProvidersMultipleFilesExample

@interface PSCDocumentDataProvidersMultipleFilesExample : PSCExample
@end
@implementation PSCDocumentDataProvidersMultipleFilesExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"MultipleFiles";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 40;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSMutableArray <PSPDFCoordinatedFileDataProvider *> *dataProviders = [NSMutableArray array];
    for (NSString *filename in @[@"A", @"B", @"C", @"D"]) {
        [dataProviders addObject:[[PSPDFCoordinatedFileDataProvider alloc] initWithFileURL:(NSURL *)[NSBundle.mainBundle URLForResource:filename withExtension:@"pdf" subdirectory:@"Samples"]]];
    }
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:dataProviders];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.annotationButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.activityButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCDocumentDataProvidersMultipleNSDataObjectsMemoryMappedExample

@interface PSCDocumentDataProvidersMultipleNSDataObjectsMemoryMappedExample : PSCExample
@end
@implementation PSCDocumentDataProvidersMultipleNSDataObjectsMemoryMappedExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Multiple NSData objects (memory mapped)";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];

    static PSPDFDocument *document;
    if (!document) {
        NSMutableArray<PSPDFDataContainerProvider *> *dataProviders = [NSMutableArray array];
        for (NSString *filename in @[@"A.pdf", @"B.pdf", @"C.pdf"]) {
            NSURL *file = [samplesURL URLByAppendingPathComponent:filename];
            NSData *data = [NSData dataWithContentsOfURL:file options:NSDataReadingMappedIfSafe error:NULL];
            [dataProviders addObject:[[PSPDFDataContainerProvider alloc] initWithData:data]];
        }
        document = [[PSPDFDocument alloc] initWithDataProviders:dataProviders];
    } else {
        // this is not needed, just an example how to use the changed dataArray (the data will be changed when annotations are written back)
        NSMutableArray<PSPDFDataContainerProvider *> *dataProviders = [NSMutableArray array];
        for (NSData *data in document.dataArray) {
            [dataProviders addObject:[[PSPDFDataContainerProvider alloc] initWithData:data]];
        }
        document = [[PSPDFDocument alloc] initWithDataProviders:dataProviders];
    }

    // make sure your NSData objects are either small or memory mapped; else you're getting into memory troubles.
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.searchButtonItem, controller.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCDocumentDataProvidersMultipleNSDataObjectsExample

@interface PSCDocumentDataProvidersMultipleNSDataObjectsExample : PSCExample
@end
@implementation PSCDocumentDataProvidersMultipleNSDataObjectsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Multiple NSData objects";
        self.category = PSCExampleCategoryDocumentDataProvider;
        self.priority = 60;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSMutableArray<PSPDFDataContainerProvider *> *dataProviders = [NSMutableArray array];
    for (NSString *filename in @[@"A.pdf", @"B.pdf", @"C.pdf"]) {
        NSData *data = [NSData dataWithContentsOfURL:(NSURL *)[samplesURL URLByAppendingPathComponent:filename]];
        [dataProviders addObject:[[PSPDFDataContainerProvider alloc] initWithData:data]];
    }
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:dataProviders];

    document.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;

    // make sure your NSData objects are either small or memory mapped; else you're getting into memory troubles.
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.searchButtonItem, controller.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end
