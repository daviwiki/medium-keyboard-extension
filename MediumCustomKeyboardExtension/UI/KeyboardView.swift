
import UIKit
import Combine
import Contacts

class KeyboardView: UIView, NibView {
    
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var errorContainerView: UIView!
    @IBOutlet private weak var toolbarView: UIView!
    @IBOutlet private weak var contactsView: ContactsCollectionView!
    private weak var filterKeyboardView: KeyboardFilterView!
        
    var selectedContact: AnyPublisher<CNContact, Never> {
        return contactsView.selectedContact
    }
    
    var viewModel: KeyboardViewModel! {
        didSet {
            commonInit()
        }
    }
    
    private var disposables = Set<AnyCancellable>()
    private var keyboardDisposables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        inflateView(from: "KeyboardView", locatedAt: .main)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        inflateView(from: "KeyboardView", locatedAt: .main)
    }
    
    private func commonInit() {
        viewModel
            .state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.draw(state)
            }
            .store(in: &disposables)
    }
    
    private func draw(_ state: KeyboardState) {
        switch state {
        case .loading:
            errorContainerView.isHidden = true
            toolbarView.isHidden = true
            contactsView.isHidden = true
        case let .contacts(contacts, editingMode):
            errorContainerView.isHidden = true
            toolbarView.isHidden = false
            contactsView.isHidden = false
            var filterKey: String? = nil
            if editingMode == .idle {
                unmountKeyboard()
            } else if case let EditingMode.edition(filter) = editingMode {
                filterKey = filter
                mountKeyboard()
            }
            contactsView.show(contacts: contacts, filterKey: filterKey)
        case .error:
            errorContainerView.isHidden = false
            toolbarView.isHidden = true
            contactsView.isHidden = true
        }
    }
    
    private func mountKeyboard() {
        guard filterKeyboardView == nil else { return }
        let keyboard = KeyboardFilterView()
        keyboard
            .keyPressed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] key in
                self?.viewModel.keyPressed(key)
            }
            .store(in: &keyboardDisposables)
        keyboard.isHidden = true
        containerStackView.addArrangedSubview(keyboard)
        UIView.animate(withDuration: 0.2) {
            keyboard.isHidden = false
        }
        self.filterKeyboardView = keyboard
    }
    
    private func unmountKeyboard() {
        guard let keyboard = filterKeyboardView else { return }
        UIView.animate(withDuration: 0.2) {
            keyboard.isHidden = true
        } completion: { _ in
            self.containerStackView.remove(keyboard)
            self.keyboardDisposables = Set<AnyCancellable>()
        }
    }
    
    func load() {
        viewModel.load()
    }
    
    @IBAction private func onSearch(button: UIButton) {
        viewModel.switchEditingMode()
    }
}

extension KeyboardView {
    static func create() -> KeyboardView {
        let view = KeyboardView()
        view.viewModel = KeyboardViewModelDefault.create()
        return view
    }
}
