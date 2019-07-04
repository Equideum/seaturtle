//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class FormInteractiveDigitalSigningExample: PSCExample {

    // MARK: Interactive digital signing process

    override init() {
        super.init()
        title = "Digital signing process (password: test)"
        category = .forms
        priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let p12URL = samplesURL.appendingPathComponent("JohnAppleseed.p12")
        let p12data = try? Data(contentsOf: p12URL)
        let p12 = PSPDFPKCS12(data: p12data!)
        let p12signer = PSPDFPKCS12Signer(displayName: "John Appleseed", pkcs12: p12)
        let signatureManager = PSPDFKit.sharedInstance.signatureManager
        signatureManager.clearRegisteredSigners()
        signatureManager.register(p12signer)
        signatureManager.clearTrustedCertificates()

        // Add certs to trust store for the signature validation process
        let certURL = samplesURL.appendingPathComponent("JohnAppleseed.p7c")
        let certData = try? Data(contentsOf: certURL)
        let certificates = try? PSPDFX509.certificates(fromPKCS7Data: certData!)
        for x509 in certificates! {
            signatureManager.addTrustedCertificate(x509)
        }
        let documentURL = samplesURL.appendingPathComponent("Form_example.pdf")
        let newURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, true)
        let document = PSPDFDocument(url: newURL)
        document.annotationSaveMode = .embedded
        return PSPDFViewController(document: document)
    }
}

class FormDigitalSigningExample: PSCExample {

    // MARK: Automated digital signing process

    override init() {
        super.init()
        title = "Automated digital signing process"
        category = .forms
        priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL =  Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let p12URL = samplesURL.appendingPathComponent("JohnAppleseed.p12")
        guard let p12data = try? Data(contentsOf: p12URL) else {
            print("Error reading p12 data from \(String(describing: p12URL))")
            return PSPDFViewController()
        }
        let p12 = PSPDFPKCS12(data: p12data)
        let signer = PSPDFPKCS12Signer(displayName: "John Appleseed", pkcs12: p12)
        signer.reason = "Contract agreement"
        let signatureManager = PSPDFKit.sharedInstance.signatureManager
        signatureManager.clearRegisteredSigners()
        signatureManager.register(signer)
        signatureManager.clearTrustedCertificates()

        // Add certs to trust store for the signature validation process
        let certURL = samplesURL.appendingPathComponent("JohnAppleseed.p7c")
        let certData = try? Data(contentsOf: certURL)
        let certificates = try? PSPDFX509.certificates(fromPKCS7Data: certData!)
        for x509 in certificates! {
            signatureManager.addTrustedCertificate(x509)
        }
        let unsignedDocument = PSPDFDocument(url: (samplesURL.appendingPathComponent("Form_example.pdf")))
        let signatureFormElement = unsignedDocument.annotationsForPage(at: 0, type: .widget).first { annotation -> Bool in
            return annotation is PSPDFSignatureFormElement
        }

        let fileName = "\(UUID().uuidString).pdf"
        let path = NSTemporaryDirectory().appending(fileName)

        var signedDocument: PSPDFDocument?
        // sign the document
        signer.sign(signatureFormElement as! PSPDFSignatureFormElement, usingPassword: "test", writeTo: path, appearance: nil, biometricProperties: nil, completion: {(_ success: Bool, _ document: PSPDFDocument, _ err: Error?) -> Void in
            signedDocument = document
        })
        return PSPDFViewController(document: signedDocument!)
    }
}

class FormFillingExample: PSCExample {

    // MARK: Programmatic Form Filling

    override init() {
        super.init()
        title = "Programmatic Form Filling"
        contentDescription = "Automatically fills out all forms in code."
        category = .forms
        priority = 30
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let document = PSPDFDocument(url: samplesURL.appendingPathComponent("Form_example.pdf"))
        document.annotationSaveMode = .disabled

        // Get all form objects and fill them in.
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            let annotations = document.annotationsForPage(at: 0, type: .widget)
            for formElement: PSPDFAnnotation in annotations where formElement is PSPDFFormElement {
                Thread.sleep(forTimeInterval: 0.8)
                // Always update the model on the main thread.
                DispatchQueue.main.async(execute: {() -> Void in
                    if let textFieldElement = formElement as? PSPDFTextFieldFormElement {
                        let fieldName = textFieldElement.fieldName ?? ""
                        if textFieldElement.inputFormat == .date {
                            textFieldElement.contents = "01/01/2001"
                        // Telephone_Home needs exactly 7 digits
                        } else if fieldName == "Telephone_Home" {
                            textFieldElement.contents = "0123456"
                        // Social Security Number needs exactly 9 digits
                        } else if fieldName == "SSN" {
                            textFieldElement.contents = "012345678"
                        // The other phone numbers need exactly 10 digits
                        } else if fieldName == "Telephone_Work" || fieldName == "Emergency_Phone" {
                            textFieldElement.contents = "0123456789"
                        // All the other form fields don't have any special validation
                        } else {
                            textFieldElement.contents = "Test \(fieldName)"
                        }
                    } else if let buttonElement = formElement as? PSPDFButtonFormElement {
                        buttonElement.toggleButtonSelectionState()
                    }
                })
            }
        })
        return FormFillingPDFViewController(document: document)
    }
}

private final class FormFillingPDFViewController: PSPDFViewController {

    // MARK: Lifecycle

    override func commonInit(with document: PSPDFDocument?, configuration: PSPDFConfiguration) {
        super.commonInit(with: document, configuration: configuration)

        let saveCopy = UIBarButtonItem(title: "Save Copy", style: .plain, target: self, action: #selector(FormFillingPDFViewController.saveCopy(_:)))
        navigationItem.setLeftBarButtonItems([pdfController.closeButtonItem, saveCopy], animated: false)
    }

    // MARK: Bar Button Item Actions

    @objc
    private func saveCopy(_ sender: UIBarButtonItem) {
        // Create a copy of the document
        let tempURL = PSCTempFileURLWithPathExtension("copy_\(document?.fileURL?.lastPathComponent ?? "Form_example")", "pdf")
        guard let documentURL = document?.fileURL else { return }
        try? FileManager.default.copyItem(at: documentURL, to: tempURL)

        // Transfer form values
        let documentCopy = PSPDFDocument(url: tempURL)
        let annotations = document?.annotationsForPage(at: 0, type: .widget)
        let annotationsCopy = documentCopy.annotationsForPage(at: 0, type: .widget)
        assert(annotations?.count == annotationsCopy.count, "This example is built to only fill forms - don't add/remove annotations.")
        for (index, formElement) in (annotationsCopy.enumerated()) {
            (formElement as? PSPDFFormElement)?.contents = (annotations![index] as? PSPDFFormElement)?.contents
        }
        try? documentCopy.save(options: [])
        guard let path = documentCopy.fileURL?.path else { return }
        let alert = UIAlertController(title: "Success", message: "Document copy saved to \(path)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

class FormDigitallySignedModifiedExample: PSCExample {

    // MARK: Interactive Form with a Digital Signature

    override init() {
        super.init()
        title = "Example of an Interactive Form with a Digital Signature"
        category = .forms
        priority = 10
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let document = PSPDFDocument(url: samplesURL.appendingPathComponent("Form_example_signed.pdf"))
        return PSPDFViewController(document: document)
    }
}

class FormWithFormatting: PSCExample {

    // MARK: Form with formatted text fields

    override init() {
        super.init()
        title = "PDF Form with formatted text fields"
        category = .forms
        priority = 50
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let document = PSPDFDocument(url: samplesURL.appendingPathComponent("Forms_formatted.pdf"))
        return PSPDFViewController(document: document)
    }
}

class FormWithFormattingReadonly: PSCExample {

    // MARK: Readonly Form

    override init() {
        super.init()
        title = "Readonly Form"
        category = .forms
        priority = 51
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let document = PSPDFDocument(url: samplesURL.appendingPathComponent("Forms_formatted.pdf"))

        let configuration = PSPDFConfiguration { builder in
            var editableAnnotationTypes = builder.editableAnnotationTypes
            editableAnnotationTypes?.remove(.widget)
            builder.editableAnnotationTypes = editableAnnotationTypes
        }
        return PSPDFViewController(document: document, configuration: configuration)
    }
}

class FormFillingAndSavingExample: PSCExample {

    // MARK: Programmatically fill form and save

    override init() {
        super.init()
        title = "Programmatically fill form and save"
        category = .forms
        priority = 150
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Get the example form and copy it to a writable location.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = PSCCopyFileURLToDocumentFolderAndOverride(samplesURL.appendingPathComponent("Form_example.pdf"), true)
        let document = PSPDFDocument(url: documentURL)
        document.annotationSaveMode = .embedded

        for formElement: PSPDFFormElement in (document.formParser?.forms)! {
            if formElement is PSPDFButtonFormElement {
                (formElement as? PSPDFButtonFormElement)?.select()
            } else if formElement is PSPDFChoiceFormElement {
                (formElement as? PSPDFChoiceFormElement)?.selectedIndices = NSIndexSet(index: 1) as IndexSet
            } else if formElement is PSPDFTextFieldFormElement {
                formElement.contents = "Test"
            }
        }

        document.save(options: [], completion: { (result) in
            switch result {
            case .failure(let error):
                print("Error while saving: \(String(describing: error.localizedDescription))")

            case .success:
                print("File saved correctly to \(documentURL.path)")
            }
        })

        return PSPDFViewController(document: document)
    }
}

class FormCreationExample: PSCExample {

    // MARK: Programmatically create a text form field

    override init() {
        super.init()
        title = "Programmatically create a text form field"
        category = .forms
        priority = 160
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Get the example form and copy it to a writable location.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = PSCCopyFileURLToDocumentFolderAndOverride(samplesURL.appendingPathComponent("Form_example.pdf"), true)
        let document = PSPDFDocument(url: documentURL)
        document.annotationSaveMode = .embedded

        // Create a new text field form element.
        let textFieldFormElement = PSPDFTextFieldFormElement()
        textFieldFormElement.boundingBox = CGRect(x: 200, y: 100, width: 200, height: 20)
        textFieldFormElement.pageIndex = 0

        // Insert a form field for the form element. It will automatically be added to the document.
        let textFormField = try! PSPDFTextFormField.insertedTextField(withFullyQualifiedName: "name", documentProvider: document.documentProviders.first!, formElement: textFieldFormElement)
        print("Text form field created successfully: \(textFormField)")

        return PSPDFViewController(document: document)
    }
}

class FormResetExample: PSCExample {

    // MARK: Programmatically reset some fields of a form PDF

    override init() {
        super.init()
        title = "Programmatically reset some fields of a form PDF"
        category = .forms
        priority = 160
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Get the example form and copy it to a writable location.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = PSCCopyFileURLToDocumentFolderAndOverride(samplesURL.appendingPathComponent("Form_example.pdf"), true)
        let document = PSPDFDocument(url: documentURL)
        document.annotationSaveMode = .embedded

        let lastNameField = document.formParser?.findField(withFullFieldName: "Name_Last")
        if lastNameField != nil {
            lastNameField!.value = "Appleseed"
        }
        let firstNameField = document.formParser?.findField(withFullFieldName: "Name_First")
        if firstNameField != nil {
            firstNameField!.value = "John"
        }
        if let checkBox = document.formParser?.findField(withFullFieldName: "HIGH SCHOOL DIPLOMA") as? PSPDFButtonFormField {
            checkBox.toggleButton(checkBox.annotations.first!)
        }
        // This should reset "High School Diploma" to default (unchecked), but "First name" and "Last name" keep their modified values.
        try! document.formParser?.resetForm([lastNameField!, firstNameField!], withFlags: .includeExclude)

        return PSPDFViewController(document: document)
    }
}

class PushButtonCreationExample: PSCExample {

    // MARK: Programmatically create a push button form field with a custom image

    override init() {
        super.init()
        title = "Programmatically create a push button form field with a custom image"
        category = .forms
        priority = 170
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Get the example form and copy it to a writable location.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = PSCCopyFileURLToDocumentFolderAndOverride(samplesURL.appendingPathComponent("Form_example.pdf"), true)
        let document = PSPDFDocument(url: documentURL)
        document.annotationSaveMode = .disabled

        // Create a push button and position them in the document.
        let pushButtonFormElement = PSPDFButtonFormElement()
        pushButtonFormElement.boundingBox = CGRect(x: 20, y: 200, width: 100, height: 83)
        pushButtonFormElement.pageIndex = 0

        // Add a URL action.
        pushButtonFormElement.action = PSPDFURLAction(urlString: "http://pspdfkit.com")

        // Create a new appearance characteristics and set its normal icon.
        let appearanceCharacteristics = PSPDFAppearanceCharacteristics()
        appearanceCharacteristics.normalIcon = UIImage(named: "exampleimage.jpg")
        pushButtonFormElement.appearanceCharacteristics = appearanceCharacteristics

        // Insert a form field for the form element. It will automatically be added to the document.
        let pushButtonFormField = try! PSPDFButtonFormField.insertedButtonField(with: .pushButton, fullyQualifiedName: "PushButton", documentProvider: document.documentProviders.first!, formElements: [pushButtonFormElement], buttonValues: ["PushButton"])
        print("Button form field created successfully: \(pushButtonFormField)")

        return PSPDFViewController(document: document)
    }
}
