
import UIKit

extension UIView {
    
    enum Edge {
        case leading(CGFloat), trailing(CGFloat), bottom(CGFloat), top(CGFloat)
    }
    
    func anchorToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return }
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }
    
    func anchorToEdges(_ edges: [Edge]) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return }
        for edge in edges {
            switch edge {
            case .leading(let value):
                leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: value).isActive = true
            case .trailing(let value):
                trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: value).isActive = true
            case .bottom(let value):
                superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: value).isActive = true
            case .top(let value):
                topAnchor.constraint(equalTo: superview.topAnchor, constant: value).isActive = true
            }
        }
    }
}

extension UIStackView {
    func remove(_ subview: UIView) {
        removeArrangedSubview(subview)
        subview.removeFromSuperview()
    }
    
    func remove(_ subviews: [UIView]) {
        subviews.forEach(remove(_:))
    }
    
    func removeAllSubviews() {
        remove(subviews)
    }
}
