import Foundation

let pp_test = ParsedPath(path: "M1,8Z")
        
let test_case_1 = pp_test.trimCommands(array: ["    M100,200 L175,270 L255,70 L160,220Z    "])
let test_case_2 = pp_test.trimCommands(array: ["   M100,200 L175,270 L255,70 L160,220Z"])
let test_case_3 = pp_test.trimCommands(array: ["M100,200 L175,270 L255,70 L160,220Z   "])
        
let result_1 = (test_case_1 == ["M100,200 L175,270 L255,70 L160,220Z"] ? "PASS" : "FAIL")
let result_2 = (test_case_2 == ["M100,200 L175,270 L255,70 L160,220Z"] ? "PASS" : "FAIL")
let result_3 = (test_case_3 == ["M100,200 L175,270 L255,70 L160,220Z"] ? "PASS" : "FAIL")
        
print("trimCommands Test Cases:")
print()
print(result_1)
print(result_2)
print(result_3)
