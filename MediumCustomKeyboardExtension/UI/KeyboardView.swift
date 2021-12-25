
import UIKit
import Combine
import Contacts

class KeyboardView: UIView, NibView {
    
    @IBOutlet private weak var errorContainerView: UIView!
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var contactsView: ContactsCollectionView!
    
    var selectedContact: AnyPublisher<CNContact, Never> {
        return contactsView.selectedContact
    }
    
    var viewModel: KeyboardViewModel! {
        didSet {
            commonInit()
        }
    }
    private var disposables = Set<AnyCancellable>()
    
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
            titleView.isHidden = true
            contactsView.isHidden = true
        case let .contacts(contacts):
            errorContainerView.isHidden = true
            titleView.isHidden = false
            contactsView.isHidden = false
            contactsView.show(contacts: contacts)
        case .error:
            errorContainerView.isHidden = false
            titleView.isHidden = true
            contactsView.isHidden = true
        }
    }
    
    func load() {
        viewModel.load()
    }
}

extension KeyboardView {
    static func create() -> KeyboardView {
        let view = KeyboardView()
        view.viewModel = KeyboardViewModelDefault.create()
        return view
    }
}
