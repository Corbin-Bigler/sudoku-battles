// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sudoku-battles-server",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.81.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(path: "../shared/simple-buffers"),
        .package(path: "../shared/sudoku-battles-communication")
    ],
    targets: [
        .executableTarget(
            name: "SudokuBattlesServer",
            dependencies: [
                .product(name: "SudokuBattlesCommunication", package: "sudoku-battles-communication"),
                .product(name: "SimpleBuffers", package: "simple-buffers"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl")
            ],
            resources: [
                .process("cert.pem"),
                .process("key.pem")
            ]
        )
    ]
)
