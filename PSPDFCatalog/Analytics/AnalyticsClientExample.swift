//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// Extending the type with custom events.
extension PSPDFAnalyticsEventName {
    static var catalogAnalyticsExampleOpen = PSPDFAnalyticsEventName(rawValue: "catalog_analytics_example_open")
    static var catalogAnalyticsExampleExit = PSPDFAnalyticsEventName(rawValue: "catalog_analytics_example_exit")
}

class AnalyticsClientExample: PSCExample, PSPDFViewControllerDelegate {

    class AnalyticsClient: PSPDFAnalyticsClient {
        func logEvent(_ event: PSPDFAnalyticsEventName, attributes: [String: Any]?) {
            print("\(event) \(String(describing: attributes))")
        }
    }

    let analyticsClient = AnalyticsClient()

    override init() {
        super.init()

        title = "Analytics Client"
        contentDescription = "Example implementation of PSPDFAnalyticsClient that logs events to console."
        category = .top
        priority = .max // this places the example at the bottom of the list, obviously ;)
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .quickStart)

        let analytics = PSPDFKit.sharedInstance.analytics

        analytics.add(analyticsClient)
        analytics.enabled = true

        let controller = PSPDFViewController(document: document)
        controller.delegate = self

        // sending custom events
        analytics.logEvent(.catalogAnalyticsExampleOpen)

        return controller
    }

    func pdfViewControllerDidDismiss(_ pdfController: PSPDFViewController) {
        let analytics = PSPDFKit.sharedInstance.analytics

        // sending custom events
        analytics.logEvent(.catalogAnalyticsExampleExit)

        analytics.remove(analyticsClient)
        analytics.enabled = false
    }
}
