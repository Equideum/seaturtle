//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import <MapKit/MapKit.h>

@interface PSCMapWidgetExample : PSCExample <PSPDFViewControllerDelegate>
@end

@implementation PSCMapWidgetExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Page with Apple Maps Widget";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // This annotation could be already in the document - we just add it programmatically for this example.
    PSPDFLinkAnnotation *linkAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"map://37.7998377,-122.400478,0.005,0.005"]];
    linkAnnotation.linkType = PSPDFLinkAnnotationBrowser;
    linkAnnotation.boundingBox = CGRectMake(100.0, 100.0, 300.0, 300.0);
    linkAnnotation.pageIndex = 0;
    [document addAnnotations:@[linkAnnotation] options:nil];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.thumbnailBarMode = PSPDFThumbnailBarModeNone;
    }]];
    pdfController.delegate = self;
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (UIView<PSPDFAnnotationPresenting> *)pdfViewController:(PSPDFViewController *)pdfController annotationView:(UIView<PSPDFAnnotationPresenting> *)annotationView forAnnotation:(PSPDFAnnotation *)annotation onPageView:(PSPDFPageView *)pageView {
    if ([annotation isKindOfClass:PSPDFLinkAnnotation.class]) {
        PSPDFLinkAnnotation *linkAnnotation = (PSPDFLinkAnnotation *)annotation;
        // example how to add a MapView with the url protocol map://lat,long,latspan,longspan
        if (linkAnnotation.linkType == PSPDFLinkAnnotationBrowser && [linkAnnotation.URL.absoluteString hasPrefix:@"map://"]) {
            // parse annotation data
            NSString *mapString = [linkAnnotation.URL.absoluteString stringByReplacingOccurrencesOfString:@"map://" withString:@""];
            NSArray<NSString *> *mapTokens = [mapString componentsSeparatedByString:@","];

            // ensure we have mapTokens count of 4 (latitude, longitude, span la, span lo)
            if (mapTokens.count == 4) {
                const CLLocationCoordinate2D location = CLLocationCoordinate2DMake((mapTokens[0]).doubleValue, (mapTokens[1]).doubleValue);

                const MKCoordinateSpan span = MKCoordinateSpanMake((mapTokens[2]).doubleValue, (mapTokens[3]).doubleValue);

                // frame is set in PSPDFViewController, but MKMapView needs the position before setting the region.
                const CGRect frame = [annotation boundingBoxForPageRect:pageView.bounds];

                MKMapView *mapView = [[MKMapView alloc] initWithFrame:frame];
                [mapView setRegion:MKCoordinateRegionMake(location, span) animated:NO];
                return (UIView<PSPDFAnnotationPresenting> *)mapView;
            }
        }
    }
    return annotationView;
}

@end
