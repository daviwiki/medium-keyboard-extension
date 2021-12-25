
import Foundation
import Combine
import Contacts

enum KeyboardState {
    case loading
    case contacts([CNContact], EditingMode)
    case error
}

typealias Filter = String

enum EditingMode: Equatable {
    case idle
    case edition(Filter)
    
    static func == (lhs: EditingMode, rhs: EditingMode) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.edition(_), .edition(_)):
            return true
        default:
            return false
        }
    }
}

protocol KeyboardViewModel {
    /**
     Order the start configuration
     */
    func load()
    
    /**
     Switch between edition and idle mode
     */
    func switchEditingMode()
    
    /**
     Select a key pressed into the keyboard
     */
    func keyPressed(_ key: KeyboardKey)
    
    /**
     Expose the MVVM state
     */
    var state: AnyPublisher<KeyboardState, Never> { get }
}

class KeyboardViewModelDefault: KeyboardViewModel {
    
    private let getContacts: GetContacts
    private var disposables = Set<AnyCancellable>()
    var state: AnyPublisher<KeyboardState, Never> {
        _state.eraseToAnyPublisher()
    }
    private let _state: PassthroughSubject<KeyboardState, Never>
    
    private var contacts: [CNContact] = []
    private var editingMode: EditingMode = .idle
    private var filter: String = ""
    
    init(getContacts: GetContacts) {
        self.getContacts = getContacts
        self._state = PassthroughSubject()
    }
    
    func load() {
        _state.send(.loading)
        getContacts
            .execute()
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .failure(_):
                    self?._state.send(.error)
                default:
                    break
                }
            } receiveValue: { [weak self] contacts in
                guard let self = self else { return }
                self.contacts = contacts
                self._state.send(.contacts(contacts, self.editingMode))
            }
            .store(in: &disposables)
    }
    
    func switchEditingMode() {
        editingMode = editingMode == .idle ? .edition(filter) : .idle
        _state.send(.contacts(contacts, self.editingMode))
    }
    
    func keyPressed(_ key: KeyboardKey) {
        switch key {
        case .empty:
            return
        case .remove:
            guard !filter.isEmpty else { return }
            filter.removeLast()
            editingMode = .edition(filter)
        case .done:
            filter = ""
            editingMode = .idle
        case let .key(stringKey):
            filter.append(stringKey)
            editingMode = .edition(filter)
        }
        
        let filterContacts = FilterContactsDefault.create()
        let contactsFiltered = filterContacts.execute(contacts: contacts, filter: filter)
        _state.send(.contacts(contactsFiltered, editingMode))
    }
}

extension KeyboardViewModelDefault {
    static func create() -> KeyboardViewModel {
        KeyboardViewModelDefault(getContacts: GetContactsDefault.create())
    }
}
