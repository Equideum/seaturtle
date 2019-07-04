//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class CustomCommentsViewControllerExample: PSCExample {

    override init() {
        super.init()

        title = "Custom Comments (Notes) UI"
        contentDescription = "Replaces PSPDFNoteAnnotationViewController with a custom view controller."
        category = .annotations
        priority = 72
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .quickStart)
        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFPageView.self, with: CustomPageView.self)
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        return controller
    }
}

class CustomPageView: PSPDFPageView {
    override func showNoteController(for annotation: PSPDFAnnotation, animated: Bool) {
        let commentsViewController = CustomCommentsViewController()
        let navigationController = UINavigationController(rootViewController: commentsViewController)
        presentationContext?.actionDelegate.present(navigationController, options: nil, animated: animated, sender: nil, completion: nil)
    }
}

class CustomCommentsViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss(sender:)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    @objc func dismiss(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
