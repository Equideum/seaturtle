//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Instant

/**
 This example connects to our public web-preview server and downloads documents using PSPDFKit Instant.
 You can then collaboratively annotate these documents using Instant.
 Each document on web-preview can be accessed using a six character code.

 The example lets you either create a new collaboration group by getting a new document code,
 or join an existing collaboration group by entering a document code.

 Other supported clients include:

 - https://pspdfkit.com/instant/demo/
 - https://web-preview.pspdfkit.com/
 - PDF Viewer for iOS
 - PDF Viewer for Android
 - The PSPDFKit Catalog example app for Android

 As is usually the case with Instant, most of the code here deals with communicating
 with the particular server backend (our web-preview server in this case).
 The code actually interacting with the Instant framework API is just a few lines contained in `InstantDocumentViewController`.
 */
class InstantExample: PSCExample {
    override init() {
        super.init()

        title = "PSPDFKit Instant"
        contentDescription = "Downloads a document for collaborative editing."
        category = .top
        priority = 2
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        return InstantExampleViewController()
    }
}

/**
 Downloads and shows a document managed by Instant, and shows a
 button to get the document code out so you can see Instant syncing.
 */
class InstantDocumentViewController: PSPDFInstantViewController {
    let documentInfo: InstantDocumentInfo
    let client: PSPDFInstantClient
    let documentDescriptor: PSPDFInstantDocumentDescriptor

    init(documentInfo: InstantDocumentInfo) throws {
        /*
         Create the Instant objects with the information from the web-preview server.

         The `PSPDFDocument` you get from Instant does not retain the objects that create it,
         so we need to keep references to the client and document descriptor otherwise with no
         strong references they would deallocate and syncing would stop.
         */
        client = try PSPDFInstantClient(serverURL: documentInfo.serverURL)
        documentDescriptor = try client.documentDescriptor(forJWT: documentInfo.jwt)

        // Store document info (which also contains the code) for sharing later.
        self.documentInfo = documentInfo

        // Tell Instant to download the document from web-preview’s PSPDFKit Server instance.
        do {
            try documentDescriptor.download(usingJWT: documentInfo.jwt)
        } catch PSPDFInstantError.alreadyDownloaded {
            // This is fine, we only have to reauthenticate. Any other errors are passed up.
            documentDescriptor.reauthenticate(withJWT: documentInfo.jwt)
        }

        // Get the `PSPDFDocument` from Instant.
        let pdfDocument = documentDescriptor.editableDocument

        // Set the document on the `PSPDFInstantViewController` (the superclass) so it can show the download progress, and then show the document.
        super.init(document: pdfDocument, configuration: nil)

        let collaborateItem = UIBarButtonItem(title: "Collaborate", style: .plain, target: self, action: #selector(showCollaborationOptions(_:)))
        let barButtonItems = [collaborateItem, annotationButtonItem]
        navigationItem.setRightBarButtonItems(barButtonItems, for: .document, animated: false)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    deinit {
        do {
            /*
             Since this demo is ephemeral, clean up immediately.
             Note that this also cancels syncing that is in-progress.
             */
            try documentDescriptor.removeLocalStorage()
        } catch {
            print("Could not remove Instant document storage: \(error)")
        }
    }

    // MARK: - End of use of Instant API

    /*
     Nothing in the rest of this file uses any API from Instant. It’s just setting up the
     UI for this particular demo and making network requests to our web-preview server.
     */

    @objc func showCollaborationOptions(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Document URL\n\(documentInfo.url)", message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.barButtonItem = sender

        alertController.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { [weak self] _ in
            UIApplication.shared.open(self!.documentInfo.url)
        }))
        alertController.addAction(UIAlertAction(title: "Share Document Link", style: .default, handler: { [weak self] _ in
            self!.showActivityViewController(with: self!.documentInfo.url, from: sender)
        }))
        alertController.addAction(UIAlertAction(title: "Share Document Code", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.showActivityViewController(with: self.documentInfo.identifier, from: sender)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true)
    }

    private func showActivityViewController(with items: Any, from barButtonItem: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: [items], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem

        self.present(activityViewController, animated: true)
    }
}

private let newGroupCellIdentifier = "new group"
private let codeFieldCellIdentifier = "code field"
private let barcodeCellIdentifier = "barcode scanner"

/// Shows UI to either get a new document code or enter an existing code.
class InstantExampleViewController: UITableViewController, UITextFieldDelegate {

    /**
     Interfaces with our web-preview server to create and access documents.

     In your own app you would connect to your own server backend to get Instant document identifiers and authentication tokens
     */
    private let apiClient = WebPreviewAPIClient()
    private lazy var instantDocPresenter = InstantDocumentPresenter()

    /// A reference to the text field in the cell so it can be disabled when starting a new group to avoid duplicate network requests.
    weak var codeTextField: UITextField?

    init() {
        super.init(style: .grouped)
        title = "PSPDFKit Instant"
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: newGroupCellIdentifier)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: codeFieldCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: barcodeCellIdentifier)
    }

    // MARK: Table view data source and delegate

    struct Row {
        let identifier: String
        let allowsHighlight: Bool
    }

    struct Section {
        let header: String?
        let rows: [Row]
        let footer: String?
    }

    /// Data to show in the table view.
    private let sections: [Section] = [
        Section(header: nil, rows: [], footer: "The PSPDFKit SDKs support Instant out of the box. Just connect your app to an Instant server and document management and syncing is taken care of."),
        Section(header: nil, rows: [Row(identifier: newGroupCellIdentifier, allowsHighlight: true)], footer: "Get a new document link, then collaborate by entering it in PSPDFKit Catalog on another device, or opening the document link in a web browser."),
        Section(header: "Join a group", rows: [Row(identifier: codeFieldCellIdentifier, allowsHighlight: false), Row(identifier: barcodeCellIdentifier, allowsHighlight: true)], footer: "Enter or Scan a document link from PSPDFKit Catalog on another device, or from a web browser showing pspdfkit.com/instant/demo or web-preview.pspdfkit.com."),
    ]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier, for: indexPath)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = tableView.tintColor
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)

        switch row.identifier {
        case newGroupCellIdentifier:
            cell.textLabel?.text = "Start a New Group"
            return cell

        case barcodeCellIdentifier:
            cell.textLabel?.text = "Scan QR Code"
            return cell

        case codeFieldCellIdentifier:
            let textField = (cell as! TextFieldCell).textField

            codeTextField = textField

            textField.delegate = self
            return cell

        default:
            fatalError("Unsupported row identifier \(row.identifier)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return sections[indexPath.section].rows[indexPath.row].allowsHighlight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowId = sections[indexPath.section].rows[indexPath.row].identifier

        switch rowId {
        case newGroupCellIdentifier:
            loadDocument(loadingMessage: "Creating") { completion in
                self.apiClient.createNewDocument(completion: completion)
            }
        case barcodeCellIdentifier:
            let scannerVC = ScannerViewController()
            scannerVC.delegate = self
            let navigationVC = UINavigationController(rootViewController: scannerVC)
            navigationVC.modalPresentationStyle = .fullScreen
            self.present(navigationVC, animated: true, completion: nil)
        default:
            fatalError("Unsupported row identifier \(rowId)")
        }
    }

    // MARK: - Text field actions and delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }

        instantDocPresenter.verify(text)
        return true
    }

    // MARK: - Server API handling

    /**
     To share code for creating a new group and joining one, this takes a closure
     to run an asynchronous API call that is passed a closure to run on completion.
     */
    private func loadDocument(loadingMessage: String, APICall: @escaping (@escaping (WebPreviewAPIClient.Result) -> Void) -> Void) {
        let textField = codeTextField
        textField?.isEnabled = false

        let progressHUDItem = PSPDFStatusHUDItem.indeterminateProgress(withText: loadingMessage)
        progressHUDItem.setHUDStyle(.black)

        progressHUDItem.push(animated: true) {
            APICall { result in
                DispatchQueue.main.async {
                    let afterHidingProgressHUD: (() -> Void)?

                    switch result {
                    case let .success(documentInfo):
                        do {
                            let instantViewController = try InstantDocumentViewController(documentInfo: documentInfo)
                            self.navigationController!.pushViewController(instantViewController, animated: true)
                            afterHidingProgressHUD = nil
                        } catch {
                            print("Could not set up Instant: \(error)")
                            afterHidingProgressHUD = {
                                let errorHUDItem = PSPDFStatusHUDItem.error(withText: error.localizedDescription)
                                errorHUDItem.pushAndPop(withDelay: 2, animated: true, completion: nil)
                            }
                        }

                    case let .failure(error):
                        afterHidingProgressHUD = {
                            let errorHUDItem = PSPDFStatusHUDItem.error(withText: error.localizedDescription)
                            errorHUDItem.pushAndPop(withDelay: 2, animated: true, completion: nil)
                        }
                    }

                    progressHUDItem.pop(animated: true, completion: afterHidingProgressHUD)
                    textField?.isEnabled = true
                }
            }
        }
    }

}

extension InstantExampleViewController: ScannerViewControllerDelegate {

    func didFinishScanning(with scan: BarcodeScanResult) {
        self.dismiss(animated: true, completion: nil)

        switch scan {
        case .success(let barcode):
            codeTextField?.text = barcode
            instantDocPresenter.verify(barcode)
        case .failure(let error):
            print("Error \(String(describing: error))")
        }
    }
}

// MARK: -

class TextFieldCell: UITableViewCell {
    let textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textField.placeholder = "Enter Document Link"

        textField.keyboardType = .alphabet
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done

        textField.font = UIFont.preferredFont(forTextStyle: .headline)

        contentView.addSubview(textField)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let availableWidth = size.width - layoutMargins.left - layoutMargins.right
        let height = layoutMargins.top + textField.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude)).height + layoutMargins.bottom
        return CGSize(width: size.width, height: max(height, 44))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textField.frame = convert(bounds.inset(by: layoutMargins), to: contentView)
    }
}
