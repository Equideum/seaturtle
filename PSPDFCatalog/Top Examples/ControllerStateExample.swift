//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKitSwift

private enum ControllerState: String {
    case normal
    case empty
    case error
    case locked

    func nextState() -> ControllerState {
        switch self {
        case .normal: return .empty
        case .empty: return .error
        case .error: return .locked
        case .locked: return .normal
        }
    }
}

// MARK: CustomStringConvertible

extension ControllerState: CustomStringConvertible {

    var description: String {
        return "State: \(rawValue)"
    }
}

class ControllerStateExample: PSCExample {

    // MARK: Properties

    private weak var pdfController: PSPDFViewController?
    private var toggleButton: UIBarButtonItem!

    private var displayState: ControllerState = .normal {
        didSet {
            guard let pdfController = pdfController else { return }
            switch displayState {
            case .normal:
                pdfController.document = PSCAssetLoader.document(withName: .quickStart)
            case .empty:
                pdfController.document = nil
            case .error:
                pdfController.document = PDFDocument(dataProviders: [PSPDFDataContainerProvider(data: Data())])
            case .locked:
                pdfController.document = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "protected.pdf"))
            }
            toggleButton.title = String(describing: displayState)
        }
    }

    // MARK: PSCExample

    override init() {
        super.init()

        title = "Controller States"
        contentDescription = "Shows default, empty, error, and locked states."
        category = .top
        priority = 1000
        toggleButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(ControllerStateExample.toggleButtonPressed(_:)))
    }

    @objc
    private func toggleButtonPressed(_ sender: UIBarButtonItem) {
        // If pressed, toggle to the next state.
        displayState = displayState.nextState()
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let items = [toggleButton!]
        let document = PSCAssetLoader.document(withName: .quickStart)

        pdfController = {
            let pdfController = PSPDFViewController(document: document)
            for viewMode: PSPDFViewMode in [.document, .documentEditor, .thumbnails] {
                pdfController.navigationItem.setRightBarButtonItems(items, for: viewMode, animated: false)
            }
            pdfController.barButtonItemsAlwaysEnabled = items
            return pdfController
        }()

        // Set displayState to trigger toggleButton title change
        displayState = .normal

        return pdfController!
    }
}
