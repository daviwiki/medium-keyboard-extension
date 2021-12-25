
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
        
    func show(contact: CNContact, filterKey: Filter? = nil) {
        contact.populate(view: self, filterKey: filterKey)
    }
}

private extension CNContact {
    
    func populate(view: ContactCollectionViewCell, filterKey: Filter?) {
        view.nameLabel.attributedText = attributtedName(view: view, using: filterKey)
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
    
    private func attributtedName(view: ContactCollectionViewCell, using filterKey: Filter?) -> NSAttributedString {
        let regularFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        let name = CNContactFormatter.string(from: self, style: .fullName) ?? ""
        let attributed = NSMutableAttributedString(
            string: name, attributes: [
                .font : regularFont
            ])
        
        guard let filterKey = filterKey else {
            return attributed
        }
        
        guard let regex = try? NSRegularExpression(pattern: filterKey, options: .caseInsensitive) else {
            return attributed
        }
        
        let boldFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        for match in regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count)) {
            attributed.addAttribute(.font, value: boldFont, range: match.range)
        }
        return attributed
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
