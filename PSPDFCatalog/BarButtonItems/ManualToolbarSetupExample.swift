//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class ManualToolbarSetupExample: PSCExample {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Manual annotation toolbar setup and management"
        contentDescription = "Flexible toolbar handling without UINavigationController or PSPDFAnnotationBarButtonItem."
        category = .barButtons
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)
        let controller = PSCManualToolbarSetupViewController(document: document!)
        delegate.currentViewController?.present(controller, animated: true)
        // Present modally, so we can more easily configure it to have a different style.
        return nil
    }
}

class PSCManualToolbarSetupViewController: UIViewController, UIToolbarDelegate, PSPDFFlexibleToolbarContainerDelegate {
    var document: PSPDFDocument?
    var pdfController: PSPDFViewController?
    var toolbar: UIToolbar?
    var flexibleToolbarContainer: PSPDFFlexibleToolbarContainer?

    // MARK: Lifecycle

    init(document: PSPDFDocument) {
        super.init(nibName: nil, bundle: nil)

        self.document = document
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createPDFViewController()
    }

    func createPDFViewController() {
        // Add PSPDFViewController as a sub-controller
        pdfController = PSPDFViewController(document: document, configuration: PSPDFConfiguration {
            $0.userInterfaceViewMode = .never
            $0.backgroundColor = .white
        })

        // Those need to be nilled out if you use the barButton items (e.g., annotationButtonItem) externally!
        pdfController?.navigationItem.leftBarButtonItems = nil
        pdfController?.navigationItem.rightBarButtonItems = nil
        addChild(pdfController!)
        pdfController?.didMove(toParent: self)
        view.addSubview((pdfController?.view)!)

        // As an example, here we're not using the UINavigationController but instead a custom UIToolbar.
        // Note that if you're going that way, you'll lose some features that PSPDFKit provides, like dynamic toolbar updating or accessibility.
        let customToolbar = UIToolbar(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: 44))
        customToolbar.delegate = self
        customToolbar.autoresizingMask = .flexibleWidth

        // Configure the toolbar items
        var toolbarItems = [UIBarButtonItem]()
        customToolbar.isTranslucent = false
        toolbarItems.append(contentsOf: [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed)), UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)])

        // Normally we would just use the annotationButtonItem and let it do all the toolbar setup and management for us.
        // Here, however we'll show how one could manually configure and show the annotation toolbar without using
        // PSPDFAnnotationBarButtonItem. Note that PSPDFAnnotationBarButtonItem handles quite a fiew more
        // cases and should in general be prefered to this simple toolbar setup.

        // It's still a good idea to check if annotations are available
        if (pdfController?.document?.canSaveAnnotations)! {
            toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(toggleToolbar)))
        }
        customToolbar.items = toolbarItems
        view.addSubview(customToolbar)
        toolbar = customToolbar
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: Annotation toolbar

    @objc func toggleToolbar(_ sender: Any) {
        if flexibleToolbarContainer != nil {
            flexibleToolbarContainer?.hideAndRemove(animated: true) { _ in }
            return
        }
        let manager: PSPDFAnnotationStateManager? = pdfController?.annotationStateManager
        let toolbar = PSPDFAnnotationToolbar(annotationStateManager: manager!)
        toolbar.matchUIBarAppearance(self.toolbar!)
        // (optional)
        let container = PSPDFFlexibleToolbarContainer(frame: view.bounds)
        container.flexibleToolbar = toolbar
        container.overlaidBar = self.toolbar
        container.containerDelegate = self
        view.addSubview(container)
        flexibleToolbarContainer = container
        container.show(animated: true)
    }

    // MARK: PSPDFFlexibleToolbarContainerDelegate

    func flexibleToolbarContainerDidHide(_ container: PSPDFFlexibleToolbarContainer) {
        flexibleToolbarContainer = nil
    }

    func flexibleToolbarContainerContentRect(_ container: PSPDFFlexibleToolbarContainer) -> CGRect {
        return (pdfController?.view?.frame)!
    }

    // MARK: Layout

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Position the pdfController content below the toolbar
        var frame: CGRect = view.bounds
        frame.origin.y = toolbar!.frame.maxY
        frame.size.height -= frame.origin.y
        pdfController?.view.frame = frame
    }

    // MARK: Public

    func setDocument(_ document: PSPDFDocument) {
        if document != self.document {
            self.document = document
            pdfController?.document = document
        }
    }

    // MARK: Private

    @objc func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }

    // MARK: UIBarPositioningDelegate
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
