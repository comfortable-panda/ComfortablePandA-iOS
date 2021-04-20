//
//  SakaiAPIs.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/04.
//
import Foundation

final class SakaiAPI {
    static let shared = SakaiAPI()
    
    func getLoginToken() -> Token {
        let urlString = "https://cas.ecs.kyoto-u.ac.jp/cas/login?service=https%3A%2F%2Fpanda.ecs.kyoto-u.ac.jp%2Fsakai-login-tool%2Fcontainer"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, timeoutInterval: 6)
        var loginToken: String?
        var execution: String?
        var tokens = Token()
        
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else { throw Login.Network }
                let regexLT = try! NSRegularExpression(pattern: "<input type=\"hidden\" name=\"lt\" value=\"(.+)\" \\/>");
                let regexEXE = try! NSRegularExpression(pattern: "<input type=\"hidden\" name=\"execution\" value=\"(.+)\" \\/>");
                let str = String(data: data, encoding: .utf8)!

                guard let resultLT = regexLT.firstMatch(in: str, options: [], range: NSRange(0..<str.count)) else {
                    throw Login.LTNotFound
                }
                guard let resultEXE = regexEXE.firstMatch(in: str, options: [], range: NSRange(0..<str.count)) else {
                    throw Login.EXENotFound
                }
                
                let start = resultLT.range(at: 1).location;
                let end = start + resultLT.range(at: 1).length;
                let start2 = resultEXE.range(at: 1).location;
                let end2 = start2 + resultEXE.range(at: 1).length;
                
                loginToken = String(str[str.index(str.startIndex, offsetBy: start)..<str.index(str.startIndex, offsetBy: end)])
                execution = String(str[str.index(str.startIndex, offsetBy: start2)..<str.index(str.startIndex, offsetBy: end2)])
                tokens = Token(LT: loginToken, EXE: execution)
            } catch _ { }
            semaphore.signal()
        }
        task.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return tokens
    }
    
    func isLoggedin() -> LoginStatus {
        var result = LoginStatus()
        
        let url = URL(string: "https://panda.ecs.kyoto-u.ac.jp/portal/")!
        let request = URLRequest(url: url, timeoutInterval: 6)
        var isLoggedin = false
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else { throw Login.Network }
                let regex = try! NSRegularExpression(pattern: "\"loggedIn\": true");
                let str = String(data: data, encoding: .utf8)!
                let result = regex.matches(in: str, options: [], range: NSRange(0..<str.count))
                isLoggedin = result.count > 0
            } catch _ {
                result.success = false
                result.error = Login.Network
            }
            semaphore.signal()
        }
        task.resume()

        _ = semaphore.wait(timeout: .distantFuture)
        result.success = isLoggedin
        
        return result
    }

    func login() -> LoginStatus {
        var result = LoginStatus()
        
        let tokens = getLoginToken()
        var ECS_ID = ""
        var Password = ""
        
        if tokens.LT == nil || tokens.EXE == nil {
            result.success = false
            result.errorMsg = ErrorMsg.FailedToGetLT.rawValue
            return result
        }
        
        if getKeychain(account: "ECS_ID").success && getKeychain(account: "Password").success {
            ECS_ID = getKeychain(account: "ECS_ID").data
            Password = getKeychain(account: "Password").data
        }else{
            result.success = false
            result.errorMsg = ErrorMsg.FailedToGetKeychain.rawValue
            return result
        }
        
        let url = URL(string: "https://cas.ecs.kyoto-u.ac.jp/cas/login?service=https%3A%2F%2Fpanda.ecs.kyoto-u.ac.jp%2Fsakai-login-tool%2Fcontainer")!  //URLを生成
        
        let data : Data = "_eventId=submit&execution=\(tokens.EXE!)&lt=\(tokens.LT!)&password=\(Password)&username=\(ECS_ID)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = data
        
        let semaphore = DispatchSemaphore(value: 0)
        var isLoggedin = false
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else { throw Login.Network }
                let regex = try! NSRegularExpression(pattern: "\"loggedIn\": true");
                let str = String(data: data, encoding: .utf8)!
                let result = regex.matches(in: str, options: [], range: NSRange(0..<str.count))
                isLoggedin = result.count > 0
            } catch _ {
                result.success = false
                result.error = Login.Network
            }
            
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        if !isLoggedin { result.errorMsg = ErrorMsg.FailedToLogin.rawValue }
        result.success = isLoggedin
        
        return result
    }
    
    func logout() -> () {
        let url = URL(string: "https://panda.ecs.kyoto-u.ac.jp/portal/logout")!
        let request = URLRequest(url: url)

        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
    }
    

    func fetchAssignmentsFromPandA() -> KadaiFetchStatus {
        var result = KadaiFetchStatus()
        let loginCheck = isLoggedin()
        if (!loginCheck.success){
            if loginCheck.error == Login.Network {
                result.success = false
                result.errorMsg = ErrorMsg.FailedToGetResponse.rawValue
                return result
            }
            let loginRes = login()
            if !loginRes.success {
                result.success = false
                result.errorMsg = loginRes.errorMsg
                return result
            }
        }
        
        let urlString = "https://panda.ecs.kyoto-u.ac.jp/direct/assignment/my.json"
        let url = URL(string: urlString)!
        var assignmentEntry: [AssignmentEntry]?
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 6)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else { throw Login.JSONParse }
                guard let kadaiList = try? JSONDecoder().decode(AssignmentCollection.self, from: data) else { throw Login.JSONParse }
                assignmentEntry = kadaiList.assignment_collection
            } catch _ {
                result.success = false
                result.errorMsg = ErrorMsg.FailedToGetKadaiList.rawValue
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
        if result.success { Saver.shared.saveKadaiFetchedTimeToStorage() }
        result.rawKadaiList = assignmentEntry
        
        return result
    }
    
    func fetchLectureInfoFromPandA() -> [LectureInfo]? {
        let loginCheck = isLoggedin()
        if (!loginCheck.success){
//            if loginCheck.error == Login.Network {
//                result.success = false
//                result.errorMsg = ErrorMsg.FailedToGetResponse.rawValue
//                return result
//            }
            let loginRes = login()
            if !loginRes.success {
                return [LectureInfo]()
            }
        }
        var lectureEntry: [LectureInfo]?
        
        let urlString = "https://panda.ecs.kyoto-u.ac.jp/direct/site.json?_limit=20"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, timeoutInterval: 10)

        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else { throw Login.JSONParse }
                guard let lectureList = try? JSONDecoder().decode(LectureCollection.self, from: data) else { throw Login.JSONParse }
                lectureEntry = lectureList.site_collection
            } catch _ {
                print("lec fetch error")
                lectureEntry = [LectureInfo]()
            }
            
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
        return lectureEntry
    }
    
    
    func getRawKadaiList() -> [AssignmentEntry] {
        var kadaiList: [AssignmentEntry]
        let res = SakaiAPI.shared.fetchAssignmentsFromPandA()
        if res.success {
            kadaiList = res.rawKadaiList!
        }else{
            kadaiList = [AssignmentEntry]()
        }
        return kadaiList
    }
    
    func getLectureInfoList() -> [LectureInfo] {
        var lectureInfoList: [LectureInfo]
        lectureInfoList = SakaiAPI.shared.fetchLectureInfoFromPandA()!
        Saver.shared.saveLectureInfoToStorage(lectureInfoList: lectureInfoList)
        return lectureInfoList
    }
}


func findLectureName(lectureInfoList: [LectureInfo], lecID: String) -> String {
    let index = lectureInfoList.firstIndex { $0.id == lecID }
    if index != nil { return lectureInfoList[index!].title.components(separatedBy: "]")[safe: 1]! }
    else{ return "不明" }
}


extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
    return (startIndex <= index && index < endIndex) ? self[index] : "不明" as! Self.Element
   }
}

enum Login: Error {
    case Default
    case Network
    case JSONParse
    case LTNotFound
    case EXENotFound
}
