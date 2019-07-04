//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomAnnotationProvider : PSPDFContainerAnnotationProvider
@end

@interface PSCCustomAnnotationProviderExample : PSCExample
@end
@implementation PSCCustomAnnotationProviderExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom AnnotationProvider";
        self.contentDescription = @"Shows how to use a custom annotation provider";
        self.category = PSCExampleCategoryAnnotationProviders;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.didCreateDocumentProviderBlock = ^(PSPDFDocumentProvider *documentProvider) {
        documentProvider.annotationManager.annotationProviders = @[[[PSCCustomAnnotationProvider alloc] initWithDocumentProvider:documentProvider]];
    };
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end

@interface PSCCustomAnnotationProvider () {
    NSMutableDictionary *_annotationDict;
    NSTimer *_timer;
}
@end

@implementation PSCCustomAnnotationProvider

@synthesize providerDelegate = _providerDelegate;

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider {
    if ((self = [super initWithDocumentProvider:documentProvider])) {
        _annotationDict = [NSMutableDictionary new];

        // add timer in a way so it works while we're dragging pages (NSRunLoopCommonModes)
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];

        // The document provider generation can happen on any thread, make sure we register on the main runloop.
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)setProviderDelegate:(id<PSPDFAnnotationProviderChangeNotifier>)providerDelegate {
    if (providerDelegate != _providerDelegate) {
        _providerDelegate = providerDelegate;

        // nil out timer to allow object to deallocate itself.
        if (!providerDelegate) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFAnnotationProvider

- (NSArray<PSPDFAnnotation *> *)annotationsForPageAtIndex:(PSPDFPageIndex)pageIndex {
    NSArray<PSPDFAnnotation *> *annotations;

    // it's important that this method is:
    // - fast
    // - thread safe
    // - and caches annotations (don't always create new objects!)
    @synchronized(self) {
        annotations = _annotationDict[@(pageIndex)];
        if (!annotations) {
            // create new note annotation and add it to the dict.
            PSPDFDocumentProvider *documentProvider = self.providerDelegate.parentDocumentProvider;
            PSPDFNoteAnnotation *noteAnnotation = [PSPDFNoteAnnotation new];
            noteAnnotation.contents = [NSString stringWithFormat:@"Annotation from the custom annotationProvider for page index %tu.", pageIndex];

            // place it top left (PDF coordinate space starts from bottom left)
            PSPDFPageInfo *pageInfo = [documentProvider.document pageInfoForPageAtIndex:pageIndex];
            noteAnnotation.boundingBox = CGRectMake(100.0, pageInfo.size.height - 100., 32.0, 32.0);

            // Set page as the last step.
            noteAnnotation.pageIndex = pageIndex;

            _annotationDict[@(pageIndex)] = @[noteAnnotation];
            annotations = @[noteAnnotation];
            noteAnnotation.editable = NO;
        }
    }
    return annotations;
}

- (NSArray<__kindof PSPDFAnnotation *> *)addAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options {
    [super addAnnotations:annotations options:options];
    // We want to apply this to all annotation that are added (this only matters when you add 2 or more annotations at the same time via copy/paste etc)
    for (PSPDFAnnotation *annotation in annotations) {
         NSArray<PSPDFAnnotation *> *existingAnnotations = _annotationDict[@(annotation.pageIndex)];
         _annotationDict[@(annotation.pageIndex)] = [existingAnnotations arrayByAddingObject:annotation];
    }
    return annotations;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// Helper to generate a random color.
static UIColor *PSCRandomColor(void) {
    CGFloat hue = arc4random() % 256 / 256.0; //  0.0 to 1.0
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5; //  0.5 to 1.0, away from white
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5; //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.];
}

// Change annotation color and notify the delegate that we have updates.
- (void)timerFired:(NSTimer *)timer {
    UIColor *color = PSCRandomColor();
    @synchronized(self) {
        [_annotationDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *page, NSArray<PSPDFAnnotation *> *annotations, BOOL *stop) {
            [annotations makeObjectsPerformSelector:@selector(setColor:) withObject:color];
            [self.providerDelegate updateAnnotations:annotations animated:YES];
        }];
    }
}

@end
