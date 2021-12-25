
import Foundation
import Combine
import Contacts

struct ContactsRepositoryDefault: ContactsRepository {
    
    func requestAccess() -> AnyPublisher<Bool, Never> {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .notDetermined else {
            return Just(status == .authorized).eraseToAnyPublisher()
        }
        
        return Future { single in
            CNContactStore().requestAccess(for: .contacts) { access, error in
                single(.success(access))
            }
        }.eraseToAnyPublisher()
    }
    
    func contacts() -> AnyPublisher<[CNContact], ContactError> {
        Future { single in
            var contacts: [CNContact] = []
            let keys: [CNKeyDescriptor] = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor
            ]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            let contactStore = CNContactStore()
            do {
                try contactStore.enumerateContacts(with: request) {
                    (contact, stop) in
                    contacts.append(contact)
                }
                single(.success(contacts))
            } catch {
                single(.failure(ContactError.couldNotRecover))
            }
        }.eraseToAnyPublisher()
    }
}
