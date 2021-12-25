
import UIKit
import Combine

enum KeyboardKey: RawRepresentable {
    
    typealias RawValue = String
    
    typealias Action = (KeyboardKey) -> ()
    case empty
    case key(String)
    case remove
    case done
    
    struct Values {
        static let empty = "empty"
        static let done = "done"
        static let remove = "remove"
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case Values.empty: self = .empty
        case Values.done: self = .done
        case Values.remove: self = .remove
        case let key: self = .key(key)
        }
    }
    
    var rawValue: String {
        switch self {
        case .empty: return Values.empty
        case .done: return Values.done
        case .remove: return Values.remove
        case let .key(value): return value
        }
    }
}
