//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class PersistSettingsOptionsExample: PSCExample, PSPDFViewControllerDelegate {
    let pageTransition = "pageTransition"
    let pageMode = "pageMode"
    let scrollDirection = "scrollDirection"
    let spreadFitting = "spreadFitting"

    override init() {
        super.init()

        title = "Persist options for PSPDFSettingsViewController"
        contentDescription = "Shows how to persist PSPDFSettingsViewController options using NSUserDefaults."
        category = .top
        priority = 21
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            // Configure the `PSPDFSettingsViewController`'s options.
            builder.settingsOptions = [.pageTransition, .pageMode, .scrollDirection, .spreadFitting]

            // Restore the settings from the user defaults.
            let defaults = UserDefaults.standard
            builder.pageTransition = PSPDFPageTransition(rawValue: UInt(defaults.integer(forKey: pageTransition)))!
            builder.pageMode = PSPDFPageMode(rawValue: UInt(defaults.integer(forKey: pageMode)))!
            builder.scrollDirection = PSPDFScrollDirection(rawValue: UInt(defaults.integer(forKey: scrollDirection)))!
            builder.spreadFitting = PSPDFConfigurationSpreadFitting(rawValue: defaults.integer(forKey: spreadFitting))!
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)

        // Configure the left bar button items.
        controller.navigationItem.setLeftBarButtonItems([controller.settingsButtonItem], animated: false)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.delegate = self
        return controller
    }

    // MARK: - PSPDFViewControllerDelegate
    func pdfViewControllerDidDismiss(_ pdfController: PSPDFViewController) {
        // Persist the settings options in the user defaults.
        let defaults = UserDefaults.standard
        defaults.set(pdfController.configuration.pageTransition.rawValue, forKey: pageTransition)
        defaults.set(pdfController.configuration.pageMode.rawValue, forKey: pageMode)
        defaults.set(pdfController.configuration.scrollDirection.rawValue, forKey: scrollDirection)
        defaults.set(pdfController.configuration.spreadFitting.rawValue, forKey: spreadFitting)
    }
}
