//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import MapKit

class MapWidgetExample: PSCExample, PSPDFViewControllerDelegate {

    override init() {
        super.init()

        title = "Page with Apple Maps Widget"
        category = .viewCustomization
        priority = 50
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .JKHF)!
        document.annotationSaveMode = .disabled

        // This annotation could be already in the document - we just add it programmatically for this example.
        let linkAnnotation = PSPDFLinkAnnotation(url: URL(string: "map://37.7998377,-122.400478,0.005,0.005")!)
        linkAnnotation.linkType = .browser
        linkAnnotation.boundingBox = CGRect(x: 100, y: 100, width: 300, height: 300)
        linkAnnotation.pageIndex = 0
        document.add(annotations: [linkAnnotation])

        let pdfController = PSPDFViewController(document: document, configuration: PSPDFConfiguration { builder in
            builder.thumbnailBarMode = .none
        })
        pdfController.delegate = self
        return pdfController
    }

    // MARK: PSPDFViewControllerDelegate

    func pdfViewController(_ pdfController: PSPDFViewController, annotationView: (UIView & PSPDFAnnotationPresenting)?, for annotation: PSPDFAnnotation, on pageView: PSPDFPageView) -> (UIView & PSPDFAnnotationPresenting)? {
        if let linkAnnotation = annotation as? PSPDFLinkAnnotation {
            // example how to add a MapView with the url protocol map://lat,long,latspan,longspan
            if linkAnnotation.linkType == .browser, let urlString = linkAnnotation.url?.absoluteString, urlString.hasPrefix("map://") {

                // parse annotation data
                let mapString = urlString.replacingOccurrences(of: "map://", with: "")
                let mapTokens = mapString.components(separatedBy: ",")

                // ensure we have mapTokens count of 4 (latitude, longitude, span la, span lo)
                if mapTokens.count == 4,
                    let latitude = Double(mapTokens[0]),
                    let longitude = Double(mapTokens[1]),
                    let latspan = Double(mapTokens[2]),
                    let longspan = Double(mapTokens[3]) {

                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                    let span = MKCoordinateSpan(latitudeDelta: latspan, longitudeDelta: longspan)

                    // frame is set in PSPDFViewController, but MKMapView needs the position before setting the region.
                    let frame = annotation.boundingBox(forPageRect: pageView.bounds)

                    let mapView = MapView(frame: frame)
                    mapView.setRegion(MKCoordinateRegion(center: location, span: span), animated: false)
                    return mapView
                }
            }
        }
        return annotationView
    }
}

// This class is needed since we can't simply add a protocol to an object in Swift, so we need to use a subclass for our mapView here
class MapView: MKMapView, PSPDFAnnotationPresenting {}
