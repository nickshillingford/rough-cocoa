import Foundation

func assertEquals(res: [PathToken], exp: [PathToken]) -> Bool {
    for i in 0...(res.count - 2) {
        if res[i] != exp[i] {
            return false
        }
    }
    return true
}

let pp_test = ParsedPath(path: "M213,100Z")

let tokenize_result_1 = pp_test.tokenize(path: "M213,100Z")
let tokenize_expected_1: [PathToken] = [
    PathToken(type: 0, data: "M"),
    PathToken(type: 1, data: "213"),
    PathToken(type: 1, data: "100"),
    PathToken(type: 0, data: "Z")
]

let tokenize_result_2 = pp_test.tokenize(path: "M107.3,64 L200,191Z")
let tokenize_expected_2: [PathToken] = [
    PathToken(type: 0, data: "M"),
    PathToken(type: 1, data: "107.3"),
    PathToken(type: 1, data: "64"),
    PathToken(type: 0, data: "L"),
    PathToken(type: 1, data: "200"),
    PathToken(type: 1, data: "191"),
    PathToken(type: 0, data: "Z")
]

let tokenize_test_case_1 = assertEquals(res: tokenize_result_1, exp: tokenize_expected_1) ? "PASS" : "FAIL"
let tokenize_test_case_2 = assertEquals(res: tokenize_result_2, exp: tokenize_expected_2) ? "PASS" : "FAIL"

print("tokenize Test Cases:")
print()
print(tokenize_test_case_1)
print(tokenize_test_case_2)

let trim_test_case_1 = pp_test.trimCommands(array: ["    M100,200 L175,270 L255,70 L160,220Z    "])
let trim_test_case_2 = pp_test.trimCommands(array: ["   M100,200 L175,270 L255,70 L160,220Z"])
let trim_test_case_3 = pp_test.trimCommands(array: ["M100,200 L175,270 L255,70 L160,220Z   "])

let trim_result_1 = (test_case_1 == ["M100,200 L175,270 L255,70 L160,220Z"] ? "PASS" : "FAIL")
let trim_result_2 = (test_case_2 == ["M100,200 L175,270 L255,70 L160,220Z"] ? "PASS" : "FAIL")
let trim_result_3 = (test_case_3 == ["M100,200 L175,270 L255,70 L160,220Z"] ? "PASS" : "FAIL")

print("trimCommands Test Cases:")
print()
print(trim_result_1)
print(trim_result_2)
print(trim_result_3)
