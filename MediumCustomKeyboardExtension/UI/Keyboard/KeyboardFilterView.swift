
import UIKit
import Combine

class KeyboardFilterView: UIView {
    
    private enum Layout: Int {
        case alphabetic
    }
    
    weak var mainContainer: UIStackView!
    var keyPressed: AnyPublisher<KeyboardKey, Never> {
        _keyPressed.eraseToAnyPublisher()
    }
    private var _keyPressed: PassthroughSubject<KeyboardKey, Never> = PassthroughSubject()
    private var disposables: Set<AnyCancellable> = Set()
    
    private let sequences: [Layout: [[KeyboardKey]]] = [
        .alphabetic: [
            "qwertyuiop".map{ KeyboardKey.key(String($0)) },
            "asdfghjklñ".map{ KeyboardKey.key(String($0)) },
            "\(KeyboardKey.Values.remove) z c v b n m \(KeyboardKey.Values.done)"
                .split(separator: " ")
                .map({ KeyboardKey(rawValue: String($0)) ?? .empty }),
        ]
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
        let mainContainer = UIStackView()
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.spacing = 4
        mainContainer.axis = .vertical
        mainContainer.alignment = .fill
        mainContainer.distribution = .fillEqually
        addSubview(mainContainer)
        mainContainer.anchorToEdges([.top(4), .bottom(4), .leading(0), .trailing(0)])
        self.mainContainer = mainContainer
        
        redrawKeyboard()
    }
    
    private func redrawKeyboard() {
        mainContainer.removeAllSubviews()
        drawAlphabeticKeyboard()
    }
    
    private func drawAlphabeticKeyboard() {
        guard let sequences = self.sequences[.alphabetic] else { return }
        for row in sequences {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            mainContainer.addArrangedSubview(rowStackView)
            for key in row {
                if let keyView = view(for: key) {
                    keyView.isUserInteractionEnabled = true
                    keyView.gesture(.tap())
                        .map({ _ in key })
                        .sink { [weak self] key in
                            self?._keyPressed.send(key)
                    }.store(in: &disposables)
                    rowStackView.addArrangedSubview(keyView)
                }
            }
        }
    }
    
    private func view(for key: KeyboardKey) -> UIView? {
        switch key {
        case .empty:
            let empty = UIView()
            empty.backgroundColor = .white
            return empty
        case .remove:
            return buildKey("delete.left")
        case .done:
            return buildKey("xmark")
        case let .key(key):
            let letter = KeyView()
            letter.textAlignment = .center
            letter.text = key
            letter.textColor = .black
            letter.font = .systemFont(ofSize: 16, weight: .medium)
            return letter
        }
    }
    
    private func buildKey(_ icon: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = .init(systemName: icon, compatibleWith: nil)
        imageView.tintColor = .black
        return view
    }
}

private class KeyView: UILabel {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let font = self.font else { return }
        
        animate(duration: 0.15,
                backgroundColor: .lightGray.withAlphaComponent(0.2),
                font: font.withSize(font.pointSize + 4))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(duration: 0.1,
                backgroundColor: .white,
                font: font.withSize(font.pointSize - 4))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(duration: 0.1,
                backgroundColor: .white,
                font: font.withSize(font.pointSize - 4))
    }
    
    private func animate(duration: TimeInterval, backgroundColor: UIColor, font: UIFont) {
        UIView.animate(withDuration: duration) {
            self.backgroundColor = backgroundColor
            self.font = font
        }
    }
}
