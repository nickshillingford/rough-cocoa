import Foundation

class ParsedPath {
    var segments: [SegmentData] = []
    let parameters: [String]!
    let values: [[String]]!
    let path: String!
    let command: Int!
    let number: Int!
    let EOD: Int!
    
    init(path: String) {
        self.parameters = [
            "A", "a", "C", "c", "H", "h", "L", "l", "M", "m", "Q", "q", "S", "s",
            "T", "t", "V", "v", "Z", "z"
        ]
        self.values = [
            ["rx", "ry", "x-axis-rotation", "large-arc-flag", "sweep-flag", "x", "y"],
            ["rx", "ry", "x-axis-rotation", "large-arc-flag", "sweep-flag", "x", "y"],
            ["x1", "y1", "x2", "y2", "x", "y"],
            ["x1", "y1", "x2", "y2", "x", "y"],
            ["x"],
            ["x"],
            ["x", "y"],
            ["x", "y"],
            ["x", "y"],
            ["x", "y"],
            ["x1", "y1", "x", "y"],
            ["x1", "y1", "x", "y"],
            ["x2", "y2", "x", "y"],
            ["x2", "y2", "x", "y"],
            ["x", "y"],
            ["x", "y"],
            ["y"],
            ["y"],
            [],
            []
        ]
        self.path = path
        self.command = 0
        self.number = 1
        self.EOD = 2
        self.parseData(path: self.path)
        self.processPoints()
    }
    
    func loadFromSegments(segments: [SegmentData]) {
        self.segments = segments
        self.processPoints()
    }
    
    func processPoints() {
        var currentPoint = [0, 0]
        var first = ["", ""]
        
        for segment in self.segments {
            let s = segment
            var d0: Int!
            var d1: Int!
            if s.data.count != 0 {
                d0 = Int(s.data[0])!
                d1 = Int(s.data[1])!
            }
            if s.key == "M" || s.key == "L" || s.key == "T" {
                s.point = [d0, d1]
            }
            else if s.key == "m" || s.key == "l" || s.key == "t" {
                s.point = [d0 + currentPoint[0], d1 + currentPoint[1]]
            }
            else if s.key == "H" {
                s.point = [d0, currentPoint[1]]
            }
            else if s.key == "h" {
                s.point = [d0 + currentPoint[0], currentPoint[1]]
            }
            else if s.key == "V" {
                s.point = [currentPoint[0], d0]
            }
            else if s.key == "v" {
                s.point = [currentPoint[0], d0 + currentPoint[1]]
            }
            else if s.key == "z" {}
            else if s.key == "Z" {
                if first[0] != ""  {
                    let f0 = Int(first[0])!
                    let f1 = Int(first[1])!
                    s.point = [f0, f1]
                }
            }
            else if s.key == "C" {
                let d4 = Int(s.data[4])!
                let d5 = Int(s.data[5])!
                s.point = [d4, d5];
            }
            else if s.key == "c" {
                let d4 = Int(s.data[4])!
                let d5 = Int(s.data[5])!
                s.point = [d4 + currentPoint[0], d5 + currentPoint[1]]
            }
            else if s.key == "S" {
                let d2 = Int(s.data[2])!
                let d3 = Int(s.data[3])!
                s.point = [d2, d3]
            }
            else if s.key == "s" {
                let d2 = Int(s.data[2])!
                let d3 = Int(s.data[3])!
                s.point = [d2 + currentPoint[0], d3 + currentPoint[1]]
            }
            else if s.key == "Q" {
                let d2 = Int(s.data[2])!
                let d3 = Int(s.data[3])!
                s.point = [d2, d3]
            }
            else if s.key == "q" {
                let d2 = Int(s.data[2])!
                let d3 = Int(s.data[3])!
                s.point = [d2 + currentPoint[0], d3 + currentPoint[1]]
            }
            else if s.key == "A" {
                let d5 = Int(s.data[5])!
                let d6 = Int(s.data[6])!
                s.point = [d5, d6]
            }
            else if s.key == "a" {
                let d5 = Int(s.data[5])!
                let d6 = Int(s.data[6])!
                s.point = [d5 + currentPoint[0], d6 + currentPoint[1]]
            }
            
            if s.key == "m" || s.key == "M" {
                first = ["", ""]
            }
            if (s.point[0] != 0) || (s.point[1] != 0) {
                currentPoint = s.point
                if first[0] == "" {
                    first[0] = String(s.point[0])
                    first[1] = String(s.point[1])
                }
            }
            if s.key == "z" || s.key == "Z" {
                first = ["", ""]
            }
        }
    }
    
    func parseData(path: String) {
        var tokens = self.tokenize(_path: path)
        var index: Int! = 0
        var token = tokens[index]
        var mode = "BOD"
        
        while !token.isType(type: self.EOD) {
            var paren_length = 0
            var params: [String] = []
            
            if mode == "BOD" {
                if token.text == "M" || token.text == "m" {
                    index = index + 1
                    let pos = self.parameters.index(of: token.text)
                    paren_length = self.values[pos!].count
                    mode = token.text
                }
                else {
                    return self.parseData(path: ("M0,0" + path))
                }
            }
            else {
                let pos = self.parameters.index(of: token.text)
                if token.isType(type: self.number) {
                    paren_length = self.values[pos!].count
                }
                else {
                    index = index + 1
                    paren_length = self.values[pos!].count
                    mode = token.text
                }
            }
            
            if (index + paren_length) < tokens.count {
                var i = index!
                while i < (index + paren_length) {
                    let number = tokens[i]
                    if number.isType(type: self.number) {
                        params.append(number.text)
                    }
                    else {
                        print("Parameter type is not a number: " + mode + "," + number.text)
                        return
                    }
                    i = i + 1
                }
                var segment: SegmentData!
                segment = SegmentData(key: mode, data: params)
                self.segments.append(segment)
                index = index + paren_length
                token = tokens[index]
                if (mode == "M") { mode = "L" }
                if (mode == "m") { mode = "l" }
            }
            else {
                print("Path data ended before all parameters were found")
            }
        }
    }
    
    func tokenize(_path: String) -> [PathToken] {
        let tokens: [PathToken] = []
        
        // todo
        
        return tokens
    }
}
