//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCTabbedBarExample.m' for the Objective-C version of this example.

class TabbedBarExample: PSCExample {

    override init() {
        super.init()

        title = "Tabbed Bar"
        contentDescription = "Opens multiple documents in a tabbed interface."
        category = .top
        priority = 5
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        return PSCTabbedExampleViewController()
    }
}

class PSCTabbedExampleViewController: PSPDFTabbedViewController, PSPDFTabbedViewControllerDelegate {
    var clearTabsButtonItem = UIBarButtonItem()

     override func commonInit(withPDFController pdfController: PSPDFViewController?) {
        super.commonInit(withPDFController: pdfController)

        // In case pdfController was nill and commonInitWithPDFController created it.
        let controller = self.pdfController

        navigationItem.leftItemsSupplementBackButton = true

        // enable automatic persistance and restore the last state
        enableAutomaticStatePersistence = true

        documentPickerController = PSPDFDocumentPickerController(directory: "/Bundle/Samples", includeSubdirectories: true, library: PSPDFKit.sharedInstance.library)

        clearTabsButtonItem = UIBarButtonItem(image: PSPDFKit.imageNamed("trash"), style: .plain, target: self, action: #selector(clearTabsButtonPressed(sender:)))

        controller.barButtonItemsAlwaysEnabled = [clearTabsButtonItem]
        controller.navigationItem.leftBarButtonItems = [clearTabsButtonItem]

        controller.setUpdateSettingsForBoundsChange { [weak self] _ in
            self?.updateBarButtonItems()
        }

        // Show some documents when starting from scratch.
        if !restoreState || documents.isEmpty {
            documents = [PSCAssetLoader.document(withName: PSCAssetName.about)!, PSCAssetLoader.document(withName: .web)!]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBarButtonItems()
    }

///////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Private

    @objc func clearTabsButtonPressed(sender: UIBarButtonItem) {
        let sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheetController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        sheetController.addAction(UIAlertAction(title: "Close All Tabs", style: UIAlertAction.Style.destructive, handler: { [weak self] _ in
            self?.documents = []
        }))
        let popoverPresentation = sheetController.popoverPresentationController
        popoverPresentation?.barButtonItem = sender

        present(sheetController, animated: true)
    }

    func updateBarButtonItems() {
        let controller = self.pdfController

        var items = [controller.thumbnailsButtonItem, controller.activityButtonItem, controller.annotationButtonItem]
        // Add more items if we have space available
        if traitCollection.horizontalSizeClass == .regular {
            items.insert(controller.outlineButtonItem, at: 2)
            items.insert(controller.searchButtonItem, at: 2)
        }
        controller.navigationItem.setRightBarButtonItems(items, for: .document, animated: false)
    }

    func updateToolbarItems() {
        clearTabsButtonItem.isEnabled = documents.isEmpty
    }

    func multiPDFController(_ multiPDFController: PSPDFMultiDocumentViewController, didChange oldDocuments: [PSPDFDocument]) {
        updateToolbarItems()
    }
}
