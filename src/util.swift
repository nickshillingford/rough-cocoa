import Foundation

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
    var point: [Int]!
    
    init(key: String, data: [String]) {
        self.key = key
        self.data = data
        self.point = [0, 0]
    }
}

class PathToken {
    let tokenType: Int!
    let text: String!
    
    init(type: Int, txt: String) {
        self.tokenType = type
        self.text = txt
    }
    
    func isType(type: Int) -> Bool {
        return self.tokenType == type
    }
}
