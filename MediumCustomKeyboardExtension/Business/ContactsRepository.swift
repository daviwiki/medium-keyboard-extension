
import Foundation
import Combine
import Contacts

protocol ContactsRepository {
    /**
     Return true if the user gives permission to access to his
     contact list. False otherwise.
     - note: if the user has not given access before, the app
     promt for request access
     */
    func requestAccess() -> AnyPublisher<Bool, Never>
    
    /**
     If possible, return the user contacts list agenda.
     - throws: `ContactError` if any problem happen
     */
    func contacts() -> AnyPublisher<[CNContact], ContactError>
}
