// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "sudoku-battles-server",
    platforms: [.macOS(.v15), .iOS(.v13)],
    products: [
        .executable(
            name: "SudokuBattlesServer",
            targets: ["SudokuBattlesServer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/orlandos-nl/MongoKitten.git", .upToNextMajor(from: "7.9.9")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.81.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(path: "../shared/sudoku-battles-data"),
        .package(path: "../../../piste")
    ],
    targets: [
        .executableTarget(
            name: "SudokuBattlesServer",
            dependencies: [
                .product(name: "Piste", package: "piste"),
                .product(name: "SudokuBattlesData", package: "sudoku-battles-data"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "MongoKitten", package: "MongoKitten"),
            ],
            resources: [
                .process("Keys/cert.pem"),
                .process("Keys/server.key")
            ]
        ),
    ]
)
