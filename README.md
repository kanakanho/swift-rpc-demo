# swift-rpc-demo

## RPC を行える範囲

RPC は `Entities` 構造体のプロパティとなっている構造体のメソッドを呼び出せるものとなっています。それ以外の機能は持ち合わせていません。

## リクエストの中身

リクエストの中身は `RequestSchema` で定義されます。

- `id` : 通信に与えられる一意な ID
- `method` : 実行するメソッド名の文字列
- `param` : 実行するメソッドの引数

>  [!WARNING]
> このRPCにはリクエストが存在しますが、レスポンスが存在しません。レスポンスが必要な場合は、リクエストで呼び出されるメソッドと対になるレスポンス用のメソッドを定義して、必要に応じてそのメソッドを呼び出すようにしてください。

```swift
enum Method: Codable {
    case user(User.Method)
    case building(Building.Method)
}

enum Param: Codable {
    case user(User.Param)
    case building(Building.Param)

    // カスタムエンコード/デコード
    init(from decoder: Decoder) throws {...}

    func encode(to encoder: Encoder) throws {...}

    private enum CodingKeys: String, CodingKey {
        case user
        case building
    }
}

struct RequestSchema: Codable {
    let id: String
    let method: Method
    let param: Param

    // イニシャライザ
    init(id: String, method: Method, param: Param) {...}

    // カスタムエンコード/デコード
    init(from decoder: any Decoder) throws {...}

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
```

## メソッドとそれを持つ構造体の定義

メソッドは `BaseEntity` を継承してします。  
それぞれの構造体は、プロパティと列挙型の `Method` と列挙型の `Param` を持っています。  
`Param` では、`Method` が持つ要素と同じものを `CodingKeys` の中に定義して、それを列挙型 `Param` の列挙型として保持します。

### メソッドを追加する場合

1. `Mathod` と `Param` にそれぞれメソッド名を定義する
2. その引数の型を `Param` に構造体 `${先頭大文字のメソッド名}Param` として定義する。
3. `CodingKeys` にメソッド名を追加し、それを `Param` の要素として `${メソッド名}(引数の型)` として定義する。
4. `Param` のメソッドである `encode` とイニシャライザである `init(from decoder: Decoder)` に適切な条件分岐を追加する。
5. 実際に呼び出すメソッドを `Entities` のメソッドか、 `Entities` のプロパティの構造体のメソッドとして定義する。（メソッドの名前は先に `Mathod` で定義した文字列を使用し、引数の型は構造体の `Param` の型を参照すること）

> [!CAUTION]
> 今回のRPCでは型安全に通信を行うため、スキーマの共通化を行っています。  
> スキーマのエンコード・デコードを `JSONDecoder` ・ `JSONEncoder` のみで完結させるために`RequestSchema` はジェネリクスを持ちません。なので、`RequestSchema` にジェネリクスを追加するような拡張を行ってはいけません。  
> `Entities` のプロパティとなる構造体にジェネリクスを持たせるのは可能ですが、ジェネリクスごとに `Entities` のプロパティするなどの工夫が必要になります。

```swift
protocol BaseEntity: Codable {
    associatedtype Method: Codable
    associatedtype Param: Codable
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
```

