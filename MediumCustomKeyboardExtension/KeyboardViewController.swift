
import UIKit
import Combine
import Contacts

class KeyboardViewController: UIInputViewController {

    private var disposables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let keyboardView = KeyboardView.create()
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        keyboardView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        keyboardView.load()
        
        keyboardView
            .selectedContact
            .sink { [weak self] contact in
                let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "-"
                let phone = contact.firstPhone ?? "-"
                self?.textDocumentProxy.clear()
                self?.textDocumentProxy.insertText("\(name), \(phone)")
            }
            .store(in: &disposables)
    }
        
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }

}

extension UITextDocumentProxy {
    func clear() {
        guard let word = documentContextBeforeInput else { return }
        for _ in 0 ..< word.count {
            deleteBackward()
        }
    }
}
