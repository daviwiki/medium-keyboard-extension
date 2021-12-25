
import UIKit

/**
    Use this protocol to inflate a view from a xib and link its view tree to an
    owner that will conform this protocol.

    How to use:
    After an initilization of the view you must call to inflateView() method ...:
    ```
    class CustomView: UIView {
       init(frame: CGRect) {
           super(frame: frame)
           inflateView()
       }
       required init?(coder aDecoder: NSCoder) {
           super(coder: aDecoder)
           inflateView()
       }
    }
    ```
*/
protocol NibView: NSObjectProtocol {
    static var nibName: String { get }
}

// MARK: Live view NibView

extension NibView where Self: UIView {
    
    static var nibName: String {
        return String(describing: Self.self)
    }
    
    /**
     - Abstract:
        This method called to `inflateView(from:locatedAt:)` with:
        * nibName -> `Self.nibName`
        * bundle -> main bundle
    */
    func inflateView() {
        inflateView(from: Self.nibName, locatedAt: .main)
    }
    
    /**
     With this method you could specify manually the name of the nibName and the
     bundle where the view is located
     - Parameter nibName: nib name to be inflated
     - Parameter bundle: bundle where nib will be searched
    */
    func inflateView(from nibName: String, locatedAt bundle: Bundle) {
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        backgroundColor = .clear
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}


