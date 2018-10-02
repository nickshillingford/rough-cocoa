import Foundation
import UIKit

class Drawing {
    let type: String
    let data: [Any]
    
    init(type: String, data: [Any]) {
        self.type = type
        self.data = data
    }
}

class SegmentData {
    let key: String!
    let data: [String]!
    var point: [CGFloat]!
    
    init(key: String, data: [String]) {
        self.key = key
        self.data = data
        self.point = [0, 0]
    }
}

class PathToken: Equatable {
    let tokenType: Int!
    let data: String!
    
    init(type: Int, data: String) {
        self.tokenType = type
        self.data = data
    }
    
    func isType(type: Int) -> Bool {
        return self.tokenType == type
    }
    
    static func == (lhs: PathToken, rhs: PathToken) -> Bool {
        return ((lhs.tokenType == rhs.tokenType) && (lhs.data == rhs.data))
    }
}
