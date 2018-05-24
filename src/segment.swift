import Foundation

class Segment {
    let left = 0
    let right = 1
    let intersects = 2
    let ahead = 3
    let behind = 4
    let seperate = 5
    let undefined = 6
    
    let px1: Double
    let py1: Double
    let px2: Double
    let py2: Double
    var xi: Double
    var yi: Double
    let a: Double
    let b: Double
    let c: Double
    
    var _undefined: Bool
    
    init(_px1: Double, _py1: Double, _px2: Double, _py2: Double) {
        self.px1 = _px1
        self.py1 = _py1
        self.px2 = _px2
        self.py2 = _py2
        self.xi = Double(Int.max)
        self.yi = Double(Int.max)
        self.a = (_py2 - _py1)
        self.b = (_px1 - _px2)
        self.c = ((_px2 * _py1) - (_px1 * _py2))
        self._undefined = false
        self.setUndefined()
    }
    
    func setUndefined() {
        self._undefined = ((self.a == 0) && (self.b == 0) && (self.c == 0))
    }
    
    func isUndefined() -> Bool {
        return self._undefined
    }
    
    func compare(segment: Segment) -> Int {
        if self.isUndefined() || segment.isUndefined() {
            return undefined
        }
        
        var grad1 = Double(Int.max)
        var grad2 = Double(Int.max)
        
        var int1 = 0
        var int2 = 0
        
        let a = self.a
        let b = self.b
        let c = self.c
        
        if abs(b) > 0.00001 {
            grad1 = (-a / b)
            int1 = Int(-c / b)
        }
        if abs(segment.b) > 0.00001 {
            grad2 = (-segment.a / segment.b)
            int2 = Int(-segment.c / segment.b)
        }
        
        if grad1 == Double(Int.max) {
            if grad2 == Double(Int.max) {
                if ((-c / a) != (-segment.c / segment.a)) {
                    return seperate
                }
                if ((self.py1 >= min(segment.py1, segment.py2)) && (self.py1 <= max(segment.py1, segment.py2))) {
                    self.xi = self.px1
                    self.yi = self.py1
                    return intersects
                }
                if ((self.py2 >= min(segment.py1, segment.py2)) && (self.py2 <= max(segment.py1, segment.py2))) {
                    self.xi = self.px2
                    self.yi = self.py2
                    return intersects
                }
                return seperate
            }
            
            self.xi = self.px1
            self.yi = (grad2 * self.xi + Double(int2))
            
            let r1 = Double((self.py1 - self.yi) * (self.yi - self.py2))
            let r2 = Double((segment.py1 - self.yi) * (self.yi - segment.py2))
            if (r1 < -0.00001) || (r2 < -0.00001) {
                return seperate
            }
            if Double(abs(segment.a)) < 0.00001 {
                let r3 = Double((segment.px1 - self.xi) * (self.xi - segment.px2))
                if r3 < -0.00001 {
                    return seperate
                }
                return intersects
            }
            return intersects
        }
        
        if grad2 == Double(Int.max) {
            self.xi = segment.px1
            self.yi = grad1 * self.xi + Double(int1)
            let r1 = Double((segment.py1 - self.yi) * (self.yi - segment.py2))
            let r2 = Double((self.py1 - self.yi) * (self.yi - self.py2))
            if r1 < -0.00001 || r2 < -0.00001 {
                return seperate
            }
            if Double(abs(a)) < 0.00001 {
                let r3 = Double((self.px1 - self.xi) * (self.xi - self.px2))
                if r3 < -0.00001 {
                    return seperate
                }
                return intersects
            }
            return intersects
        }
        
        if grad1 == grad2 {
            if int1 != int2 {
                return seperate
            }
            if ((self.px1 >= min(segment.px1, segment.px2)) && (self.px1 <= max(segment.py1, segment.py2))) {
                self.xi = self.px1
                self.yi = self.py1
                return intersects
            }
            if ((self.px2 >= min(segment.px1, segment.px2)) && (self.px2 <= max(segment.px1, segment.px2))) {
                self.xi = self.px2
                self.yi = self.py2
                return intersects
            }
            return seperate
        }
        
        self.xi = Double(int2 - int1) / (grad1 - grad2)
        self.yi = (grad1 * self.xi + Double(int1))
        
        let r1 = Double((self.px1 - self.xi) * (self.xi - self.px2))
        let r2 = Double((segment.px1 - self.xi) * (self.xi - segment.px2))
        
        if r1 < -0.00001 || r2 < -0.00001 {
            return seperate
        }
        return intersects
    }
    
    func getLength() -> Double {
        return self._getLength(x1: self.px1, y1: self.py1, x2: self.px2, y2: self.py2)
    }
    
    func _getLength(x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
        let dx = x2 - x1
        let dy = y2 - y1
        return sqrt(Double(dx * dx) + Double(dy * dy))
    }
}
