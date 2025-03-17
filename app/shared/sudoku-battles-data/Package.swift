// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sudoku-battles-data",
    platforms: [.macOS(.v15), .iOS(.v13)],
    products: [
        .library(
            name: "SudokuBattlesData",
            targets: ["SudokuBattlesData"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orlandos-nl/MongoKitten.git", .upToNextMajor(from: "7.9.9")),
        .package(path: "../../../../piste")
    ],
    targets: [
        .target(
            name: "SudokuBattlesData",
            dependencies: [
                .product(name: "Piste", package: "piste"),
                .product(name: "Meow", package: "MongoKitten")
            ]
        ),
    ]
)
