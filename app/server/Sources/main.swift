// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Piste
import SudokuBattlesData

let certPath = Bundle.module.path(forResource: "cert", ofType: "pem")!
let keyPath = Bundle.module.path(forResource: "server", ofType: "key")!
let server = try PisteServer(host: "0.0.0.0", port: 8080, cert: certPath, key: keyPath)

server.registerService(UserSetUsernameService.self) { frame async in
    return .init(status: .success)
}
 
//Task {
    print("asdf")
    do {
        let mongoDs = try await MongoDs()
        try await mongoDs.insertUser()
        print("Finished")
    } catch {
        print(error)
    }
    print("asdf1")
//}


//try server.run()


