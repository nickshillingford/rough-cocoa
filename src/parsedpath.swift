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
        var tokens = self.tokenize(path: path)
        var index: Int! = 0
        var token = tokens[index]
        var mode = "BOD"
        
        while !token.isType(type: self.EOD) {
            var paren_length = 0
            var params: [String] = []
            
            if mode == "BOD" {
                if token.data == "M" || token.data == "m" {
                    index = index + 1
                    let pos = self.parameters.index(of: token.data)
                    paren_length = self.values[pos!].count
                    mode = token.data
                }
                else {
                    return self.parseData(path: ("M0,0" + path))
                }
            }
            else {
                let pos = self.parameters.index(of: token.data)
                if token.isType(type: self.number) {
                    paren_length = self.values[pos!].count
                }
                else {
                    index = index + 1
                    paren_length = self.values[pos!].count
                    mode = token.data
                }
            }
            
            if (index + paren_length) < tokens.count {
                var i = index!
                while i < (index + paren_length) {
                    let number = tokens[i]
                    if number.isType(type: self.number) {
                        params.append(number.data)
                    }
                    else {
                        print("Parameter type is not a number: " + mode + "," + number.data)
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
    
    func tokenize(path: String) -> [PathToken] {
        var commands: [String]!
        var values: [String]!
        var str: String = ""
        for char in path {
            if char == "-" { str += " " }
            str += String(char)
        }
        values = str.components(separatedBy: CharacterSet.init(charactersIn: "0123456789.-").inverted)
        commands = str.components(separatedBy: CharacterSet.decimalDigits)
        commands = trimCommands(array: commands)
        commands = filterCommands(array: commands)
        values = filterValues(array: values)
        return processCommands(commands: commands, values: values)
    }
    
    func processCommands(commands: [String], values: [String]) -> [PathToken] {
        var tokens: [PathToken] = []
        var c = commands
        var v = values
        while c.count != 0 {
            tokens.append(PathToken(type: 0, data: c[0]))
            if c[0] == "M" || c[0] == "m" || c[0] == "L" || c[0] == "l" ||
                c[0] == "T" || c[0] == "t" {
                tokens.append(PathToken(type: 1, data: v[0]))
                tokens.append(PathToken(type: 1, data: v[1]))
                let range = 0...1
                v.removeSubrange(range)
            }
            else if c[0] == "H" || c[0] == "h" || c[0] == "V" || c[0] == "v" {
                tokens.append(PathToken(type: 1, data: v[0]))
                v.remove(at: 0)
            }
            else if c[0] == "S" || c[0] == "s" || c[0] == "Q" || c[0] == "q" {
                tokens.append(PathToken(type: 1, data: v[0]))
                tokens.append(PathToken(type: 1, data: v[1]))
                tokens.append(PathToken(type: 1, data: v[2]))
                tokens.append(PathToken(type: 1, data: v[3]))
                let range = 0...3
                v.removeSubrange(range)
            }
            else if c[0] == "C" || c[0] == "c" {
                tokens.append(PathToken(type: 1, data: v[0]))
                tokens.append(PathToken(type: 1, data: v[1]))
                tokens.append(PathToken(type: 1, data: v[2]))
                tokens.append(PathToken(type: 1, data: v[3]))
                tokens.append(PathToken(type: 1, data: v[4]))
                tokens.append(PathToken(type: 1, data: v[5]))
                let range = 0...5
                v.removeSubrange(range)
            }
            else if c[0] == "A" || c[0] == "a" {
                tokens.append(PathToken(type: 1, data: v[0]))
                tokens.append(PathToken(type: 1, data: v[1]))
                tokens.append(PathToken(type: 1, data: v[2]))
                tokens.append(PathToken(type: 1, data: v[3]))
                tokens.append(PathToken(type: 1, data: v[4]))
                tokens.append(PathToken(type: 1, data: v[5]))
                tokens.append(PathToken(type: 1, data: v[6]))
                let range = 0...6
                v.removeSubrange(range)
            }
            else {
                tokens.append(PathToken(type: 2, data: "end"))
            }
            c.remove(at: 0)
        }
        return tokens
    }
    
    func filterCommands(array: [String]) -> [String] {
        var filtered = array
        filtered = filtered.filter {
            $0 == "M" || $0 == "m" || $0 == "C" || $0 == "c" ||
            $0 == "A" || $0 == "a" || $0 == "H" || $0 == "h" ||
            $0 == "L" || $0 == "l" || $0 == "Q" || $0 == "q" ||
            $0 == "S" || $0 == "s" || $0 == "T" || $0 == "t" ||
            $0 == "V" || $0 == "v" || $0 == "Z" || $0 == "z"
        }
        return filtered
    }
    
    func filterValues(array: [String]) -> [String] {
        var filtered = array
        filtered = filtered.filter {
            $0 != ""
        }
        return filtered
    }
    
    func trimCommands(array: [String]) -> [String] {
        var commands: [String] = []
        for command in array {
            var cmd = command
            cmd = cmd.trimmingCharacters(in: .whitespaces)
            commands.append(cmd)
        }
        return commands
    }
}
