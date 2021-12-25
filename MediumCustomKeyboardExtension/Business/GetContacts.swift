
import Foundation
import Contacts
import Combine

enum ContactError: Error {
    case accessNotAllowed
    case couldNotRecover
}

/**
 Return the user contact list or an error if something happens
 - note: a user request permissions could be ask the first time
 */
protocol GetContacts {
    func execute() -> AnyPublisher<[CNContact], ContactError>
}

struct GetContactsDefault: GetContacts {
    
    private let contactsRepository: ContactsRepository
    
    init(contactsRepository: ContactsRepository) {
        self.contactsRepository = contactsRepository
    }
    
    func execute() -> AnyPublisher<[CNContact], ContactError> {
        contactsRepository
            .requestAccess()
            .setFailureType(to: ContactError.self)
            .flatMap({ access -> AnyPublisher<[CNContact], ContactError> in
                if !access {
                    return Fail(error: ContactError.accessNotAllowed).eraseToAnyPublisher()
                }
                return self.contactsRepository.contacts().eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

extension GetContacts {
    static func create() -> GetContacts {
        GetContactsDefault(contactsRepository: ContactsRepositoryDefault())
    }
}
