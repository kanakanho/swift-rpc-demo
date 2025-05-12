//
//  Entities.swift
//  swift-rpc-demo
//
//  Created by blueken on 2025/05/12.
//

import Foundation

// 基底クラス
protocol BaseEntity: Codable {
    associatedtype Method: Codable
    associatedtype Param: Codable
}

// User クラス
struct User: BaseEntity {
    let id: String
    var name: String
    var email: String
    
    enum Method: String, Codable {
        case createUser
        case deleteUser
        case updateUser
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
    }
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }
    
    enum Param: Codable {
        case createUser(CreateUserParam)
        case deleteUser(DeleteUserParam)
        case updateUser(UpdateUserParam)
        
        struct CreateUserParam: Codable {
            let id: String
            let name: String
            let email: String
        }
        
        struct DeleteUserParam: Codable {
            let userId: String
        }
        
        struct UpdateUserParam: Codable {
            let userId: String
            let newName: String?
            let newEmail: String?
        }
        
        // カスタムエンコード/デコード
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .createUser(let param):
                try container.encode(param, forKey: .createUser)
            case .deleteUser(let param):
                try container.encode(param, forKey: .deleteUser)
            case .updateUser(let param):
                try container.encode(param, forKey: .updateUser)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let param = try? container.decode(CreateUserParam.self, forKey: .createUser) {
                self = .createUser(param)
            } else if let param = try? container.decode(DeleteUserParam.self, forKey: .deleteUser) {
                self = .deleteUser(param)
            } else if let param = try? container.decode(UpdateUserParam.self, forKey: .updateUser) {
                self = .updateUser(param)
            } else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.createUser, in: container, debugDescription: "Invalid parameter type")
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case createUser
            case deleteUser
            case updateUser
        }
    }
}

// Building クラス
struct Building: BaseEntity {
    let id: String
    var name: String
    var address: String
    var residents: [String] // ユーザーIDのリスト
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.residents = try container.decode([String].self, forKey: .residents)
    }
    
    init(id: String, name: String, address: String, residents: [String]) {
        self.id = id
        self.name = name
        self.address = address
        self.residents = residents
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(residents, forKey: .residents)
    }
    
    enum Method: String, Codable {
        case addBuilding
        case updateBuilding
        case deleteBuilding
    }
    
    enum Param: Codable {
        case addBuilding(AddBuildingParam)
        case updateBuilding(UpdateBuildingParam)
        case deleteBuilding(DeleteBuildingParam)
        
        struct AddBuildingParam: Codable {
            let id: String
            let name: String
            let address: String
            let residents: [String] // ユーザーIDのリスト
        }
        
        struct UpdateBuildingParam: Codable {
            let buildingId: String
            let newName: String?
            let newAddress: String?
            let newResidents: [String]?
        }
        
        struct DeleteBuildingParam: Codable {
            let buildingId: String
        }
        
        // カスタムエンコード/デコード
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .addBuilding(let param):
                try container.encode(param, forKey: .addBuilding)
            case .updateBuilding(let param):
                try container.encode(param, forKey: .updateBuilding)
            case .deleteBuilding(let param):
                try container.encode(param, forKey: .deleteBuilding)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let param = try? container.decode(AddBuildingParam.self, forKey: .addBuilding) {
                self = .addBuilding(param)
            } else if let param = try? container.decode(UpdateBuildingParam.self, forKey: .updateBuilding) {
                self = .updateBuilding(param)
            } else if let param = try? container.decode(DeleteBuildingParam.self, forKey: .deleteBuilding) {
                self = .deleteBuilding(param)
            } else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.addBuilding, in: container, debugDescription: "Invalid parameter type")
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case addBuilding
            case updateBuilding
            case deleteBuilding
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case residents
    }
}

struct ErrorEntitiy: BaseEntity {
    private let message: String
    
    init(message: String) {
        self.message = message
    }
    
    enum Method: String, Codable {
        case error
    }
    
    enum Param: Codable {
        case error(ErrorParam)
        
        struct ErrorParam: Codable {
            let errorMessage: String
        }
        
        // カスタムエンコード/デコード
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .error(let param):
                try container.encode(param, forKey: .error)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let param = try? container.decode(ErrorParam.self, forKey: .error) {
                self = .error(param)
            } else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.error, in: container, debugDescription: "Invalid parameter type")
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case error
        }
    }
}

// User と Building のメソッドから自動的に生成される enum
enum Method: Codable {
    case user(User.Method)
    case building(Building.Method)
}

enum Param: Codable {
    case user(User.Param)
    case building(Building.Param)
    
    // カスタムエンコード/デコード
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .user(let param):
            try container.encode(param, forKey: .user)
        case .building(let param):
            try container.encode(param, forKey: .building)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let param = try? container.decode(User.Param.self, forKey: .user) {
            self = .user(param)
        } else if let param = try? container.decode(Building.Param.self, forKey: .building) {
            self = .building(param)
        } else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.user, in: container, debugDescription: "Invalid parameter type")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case user
        case building
    }
}

// 型安全な RequestSchema
struct RequestSchema: Codable {
    let id: String
    let method: Method
    let param: Param
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.method = try container.decode(Method.self, forKey: .method)
        self.param = try container.decode(Param.self, forKey: .param)
    }
    
    init(id: String, method: Method, param: Param) {
        self.id = id
        self.method = method
        self.param = param
    }
    
    init(id: String, method: User.Method, param: User.Param) {
        self.id = id
        self.method = .user(method)
        self.param = .user(param)
    }
    
    init(id: String, method: Building.Method, param: Building.Param) {
        self.id = id
        self.method = .building(method)
        self.param = .building(param)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(param, forKey: .param)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case method
        case param
    }
}

struct Users {
    var users: [User] = []
    
    mutating func createUser(param: User.Param.CreateUserParam) -> Bool {
        let newUser = User(id: param.id, name: param.name, email: param.email)
        users.append(newUser)
        return true
    }
    
    mutating func deleteUser(param: User.Param.DeleteUserParam) -> Bool {
        users.removeAll { $0.id == param.userId }
        if users.map({ $0.id }).contains(param.userId) {
            return false
        }
        return true
    }
    
    mutating func updateUser(param: User.Param.UpdateUserParam) -> Bool {
        guard let index = users.firstIndex(where: { $0.id == param.userId }) else {
            return false
        }
        if let newName = param.newName {
            users[index].name = newName
        }
        if let newEmail = param.newEmail {
            users[index].email = newEmail
        }
        return true
    }
}

struct Buildings {
    var buildings: [Building] = []
    
    mutating func addBuilding(param: Building.Param.AddBuildingParam) -> Bool {
        let newBuilding = Building(id: param.id, name: param.name, address: param.address, residents: param.residents)
        buildings.append(newBuilding)
        return true
    }
    
    mutating func deleteBuilding(param: Building.Param.DeleteBuildingParam) -> Bool {
        buildings.removeAll { $0.id == param.buildingId }
        if buildings.map({ $0.id }).contains(param.buildingId) {
            return false
        }
        return true
    }
    
    mutating func updateBuilding(param: Building.Param.UpdateBuildingParam) -> Bool {
        guard let index = buildings.firstIndex(where: { $0.id == param.buildingId }) else {
            return false
        }
        if let newName = param.newName {
            buildings[index].name = newName
        }
        if let newAddress = param.newAddress {
            buildings[index].address = newAddress
        }
        if let newResidents = param.newResidents {
            buildings[index].residents = newResidents
        }
        return true
    }
}

struct Entities {
    var users = Users()
    var buildings = Buildings()
    
    mutating func sendRequest(request: RequestSchema) {
        switch (request.method, request.param) {
        case let (.user(.createUser), .user(.createUser(p))):
            if !users.createUser(param: p) {
                error(message: "User creation failed")
            }
        case let (.user(.updateUser), .user(.updateUser(p))):
            if !users.updateUser(param: p) {
                error(message: "User update failed")
            }
        case let (.user(.deleteUser), .user(.deleteUser(p))):
            if !users.deleteUser(param: p) {
                error(message: "User deletion failed")
            }
        case let (.building(.addBuilding), .building(.addBuilding(p))):
            if !buildings.addBuilding(param: p) {
                error(message: "Building creation failed")
            }
        case let (.building(.updateBuilding), .building(.updateBuilding(p))):
            if !buildings.updateBuilding(param: p) {
                error(message: "Building update failed")
            }
        case let (.building(.deleteBuilding), .building(.deleteBuilding(p))):
            if !buildings.deleteBuilding(param: p) {
                error(message: "Building deletion failed")
            }
        default:
            return
        }
        // リクエストを送信
        // sendRequestToPeer(request)
    }
    
    mutating func receiveRequest(request: RequestSchema) {
        switch (request.method, request.param) {
        case let (.user(.createUser), .user(.createUser(p))):
            if !users.createUser(param: p) {
                error(message: "User creation failed")
            }
        case let (.user(.updateUser), .user(.updateUser(p))):
            if !users.updateUser(param: p) {
                error(message: "User update failed")
            }
        case let (.user(.deleteUser), .user(.deleteUser(p))):
            if !users.deleteUser(param: p) {
                error(message: "User deletion failed")
            }
        case let (.building(.addBuilding), .building(.addBuilding(p))):
            if !buildings.addBuilding(param: p) {
                error(message: "Building creation failed")
            }
        case let (.building(.updateBuilding), .building(.updateBuilding(p))):
            if !buildings.updateBuilding(param: p) {
                error(message: "Building update failed")
            }
        case let (.building(.deleteBuilding), .building(.deleteBuilding(p))):
            if !buildings.deleteBuilding(param: p) {
                error(message: "Building deletion failed")
            }
        default:
            return
        }
    }
    
    func error(message: String) {
        // エラーメッセージを生成
        let errorMessage = ErrorEntitiy(message: message)
        // エラーメッセージをエンコード
        let encoder = JSONEncoder()
        guard let request = try? encoder.encode(errorMessage) else {
            print("Failed to encode error message")
            return
        }
        // クライアントにエラーメッセージを送信
        // sendRequestToPeer(request: request)
    }
}

var toClientMessage = ""

struct HostEntity {
    var entities = Entities()
    
    mutating func sendRequest(request: RequestSchema) {
        entities.sendRequest(request: request)
    }
    
    mutating func receiveRequest(request: Data) {
        // データをデコードしてリクエストを取得
        let decoder = JSONDecoder()
        guard let request = try? decoder.decode(RequestSchema.self, from: request) else {
            print("Failed to decode request")
            return
        }
        // リクエストを処理
        entities.receiveRequest(request: request)
    }
}

struct ClientEntity {
    var entities = Entities()
    
    mutating func sendRequest(request: RequestSchema) {
        entities.sendRequest(request: request)
    }
    
    mutating func receiveRequest(request: Data) {
        // データをデコードしてリクエストを取得
        let decoder = JSONDecoder()
        guard let request = try? decoder.decode(RequestSchema.self, from: request) else {
            print("Failed to decode request")
            return
        }
        // リクエストを処理
        entities.receiveRequest(request: request)
    }
}


func main(){
    // サンプルデータ
    var host = HostEntity()
    var client = ClientEntity()
    
    // リクエストの作成
    let createUserParam = User.Param.createUser(User.Param.CreateUserParam(id: "3", name: "emi", email: "emi@example.com"))
    let request = RequestSchema(id: "1", method: .user(.createUser), param: .user(createUserParam))
    // リクエストを送信
    host.sendRequest(request: request)
    // クライアントがリクエストを受信
    let requestData = try! JSONEncoder().encode(request)
    client.receiveRequest(request: requestData)
    // ユーザーの作成を確認
    if let newUser = client.entities.users.users.first(where: { $0.id == "3" }) {
        print("New user created: \(newUser.name)")
    } else {
        print("Failed to create new user")
    }
    
    print(host.entities.users.users.description)
    print(client.entities.users.users.description)
}
