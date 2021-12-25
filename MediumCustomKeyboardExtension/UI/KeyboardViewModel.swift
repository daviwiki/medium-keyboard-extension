
import Foundation
import Combine
import Contacts

enum KeyboardState {
    case loading
    case contacts([CNContact])
    case error
}

protocol KeyboardViewModel {
    func load()
    var state: AnyPublisher<KeyboardState, Never> { get }
}

class KeyboardViewModelDefault: KeyboardViewModel {
    
    private let getContacts: GetContacts
    private var disposables = Set<AnyCancellable>()
    var state: AnyPublisher<KeyboardState, Never> {
        _state.eraseToAnyPublisher()
    }
    private let _state: PassthroughSubject<KeyboardState, Never>
    
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
                self?._state.send(.contacts(contacts))
            }
            .store(in: &disposables)
    }
}

extension KeyboardViewModelDefault {
    static func create() -> KeyboardViewModel {
        KeyboardViewModelDefault(getContacts: GetContactsDefault.create())
    }
}
