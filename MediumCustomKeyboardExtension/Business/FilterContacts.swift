
import Foundation
import Contacts

protocol FilterContacts {
    
    /**
     Filter the contacts from `contacs` using the given filter
     */
    func execute(contacts: [CNContact], filter: Filter?) -> [CNContact]
}

struct FilterContactsDefault: FilterContacts {
    func execute(contacts: [CNContact], filter: Filter?) -> [CNContact] {
        guard let filter = filter else { return contacts }
        return contacts.filter { contact in
            guard !filter.isEmpty else { return true }
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
            return name.lowercased().contains(filter)
        }
    }
}

extension FilterContacts {
    static func create() -> FilterContacts {
        FilterContactsDefault()
    }
}
