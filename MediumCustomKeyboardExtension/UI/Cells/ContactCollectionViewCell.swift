
import UIKit
import Contacts

class ContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var bubbleView: UIView!
    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    @IBOutlet fileprivate weak var acronymLabel: UILabel!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var phoneLabel: UILabel!
        
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleView.layer.cornerRadius = bubbleView.bounds.width / 2
    }
        
    func show(contact: CNContact) {
        contact.populate(view: self)
    }
}

private extension CNContact {
    static let digitsKey: String = "digits"
    static let countryKey: String = "initialCountryCode"
    
    func populate(view: ContactCollectionViewCell) {
        view.nameLabel.text = CNContactFormatter.string(from: self, style: .fullName)
        view.acronymLabel.text = namePrefix
        
        if let number = firstPhone {
            view.phoneLabel.text = number
        }
        
        if let imageData = imageData, let image = UIImage(data: imageData) {
            view.profileImageView.image = image
            view.profileImageView.isHidden = false
            view.acronymLabel.isHidden = true
        } else {
            view.acronymLabel.text = acronym(length: 2)
            view.profileImageView.isHidden = true
            view.acronymLabel.isHidden = false
        }
    }
}

private extension CNContact {
    func acronym(length: Int) -> String {
        let name = CNContactFormatter.string(from: self, style: .fullName) ?? ""
        let result = name
            .components(separatedBy: " ")
            .compactMap({ $0.first?.uppercased() })
            .joined(separator: "")
            .prefix(length)
        return String(result)
    }
}

extension CNContact {
    var firstPhone: String? {
        phoneNumbers.first?.value.stringValue
    }
}
