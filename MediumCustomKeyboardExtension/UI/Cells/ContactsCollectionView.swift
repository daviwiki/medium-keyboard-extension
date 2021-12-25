
import UIKit
import Combine
import Contacts

class ContactsCollectionView: UICollectionView {
    
    static let cellReuseId: String = "contactcell"
    
    private var contacts: [CNContact] = []
    private var filterKey: Filter? = nil
    var selectedContact: AnyPublisher<CNContact, Never> {
        return _selectedContact.eraseToAnyPublisher()
    }
    private let _selectedContact: PassthroughSubject<CNContact, Never> = PassthroughSubject()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "ContactCollectionViewCell", bundle: .main)
        register(nib, forCellWithReuseIdentifier: Self.cellReuseId)
        collectionViewLayout = collectionViewLayout()
        dataSource = self
        delegate = self
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.2))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        group.interItemSpacing = .flexible(16)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func show(contacts: [CNContact], filterKey: Filter? = nil) {
        self.contacts = contacts
        self.filterKey = filterKey
        reloadData()
    }
}

extension ContactsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                cell?.transform = CGAffineTransform.identity
                    .scaledBy(x: 1.1, y: 1.1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                cell?.transform = .identity
            }
        } completion: { [weak self] _ in
            self?._selectedContact.send(contact)
        }
    }
}

extension ContactsCollectionView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellReuseId, for: indexPath)
        if let cell = cell as? ContactCollectionViewCell {
            cell.show(contact: contacts[indexPath.row], filterKey: filterKey)
        }
        return cell
    }
}

