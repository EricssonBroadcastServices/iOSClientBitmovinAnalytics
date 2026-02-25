// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

protocol DiskStorageProtocol {
    func write(_ data: Data, for key: String) throws
    func read(for key: String) throws -> Data?
    func readAll() throws -> [Data]
    func removeAll() throws
}

extension DiskStorageProtocol {
    func writePayload(
        _ payload: [String: Any],
        key: String = UUID().uuidString,
        serializer: ([String: Any]) throws -> Data = { payload in
            try JSONSerialization.data(withJSONObject: payload)
        }
    ) {
        do {
            let data = try serializer(payload)
            try write(data, for: key)
        } catch {
            logError("Failed to write payload to disk storage", error: error)
        }
    }

    func readPayload(
        for key: String,
        deserializer: (Data) throws -> [String: Any] = { data in
            try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        }
    ) -> [String: Any]? {
        do {
            guard let data = try read(for: key) else { return nil }
            let json = try deserializer(data)
            return json
        } catch {
            logError("Failed to read payload for key \(key)", error: error)
            return nil
        }
    }

    func readAllPayloads(
        deserializer: (Data) throws -> [String: Any] = { data in
            try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        }
    ) -> [[String: Any]] {
        var result: [[String: Any]] = []

        do {
            let dataFiles = try readAll()

            for data in dataFiles {
                let json = try deserializer(data)
                result.append(json)
            }
        } catch {
            logError("Failed to read payloads from disk storage", error: error)
        }

        return result
    }

    func clear() {
        do {
            try removeAll()
        } catch {
            logError("Failed to clear disk storage", error: error)
        }
    }
}

final class DiskStorage: DiskStorageProtocol {
    private let fileManager: FileManager
    private let directory: URL
    private let writingOptions: Data.WritingOptions
    private let maxStoredFiles: Int

    init?(
        baseFolderName: String = "iOSClientBitmovinAnalytics",
        folderNameSuffix: String,
        fileManager: FileManager = .default,
        writingOptions: Data.WritingOptions = [.atomic],
        maxStoredFiles: Int
    ) {
        self.fileManager = fileManager
        self.writingOptions = writingOptions
        self.maxStoredFiles = maxStoredFiles
        do {
            directory = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent(baseFolderName + folderNameSuffix, isDirectory: true)
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            logError("Failed to create DiskStorage", error: error)
            return nil
        }
    }

    func write(_ data: Data, for key: String) throws {
        try removeOldestFilesIfExceedingLimit()
        let url = fileURL(forKey: key)
        try data.write(to: url, options: writingOptions)
    }

    func read(for key: String) throws -> Data? {
        let url = fileURL(forKey: key)

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        return try Data(contentsOf: url)
    }

    func readAll() throws -> [Data] {
        var result: [Data] = []

        let files = try fileManager.contentsOfDirectory(atPath: directory.path)

        for fileName in files where fileName.hasSuffix(".json") {
            let url = directory.appendingPathComponent(fileName)

            guard fileManager.fileExists(atPath: url.path) else { continue }

            let data = try Data(contentsOf: url)
            result.append(data)
        }

        return result
    }

    func removeAll() throws {
        let files = try fileManager.contentsOfDirectory(atPath: directory.path)

        for fileName in files where fileName.hasSuffix(".json") {
            let url = directory.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        }
    }
}

// MARK: - Private methods
extension DiskStorage {
    private func fileURL(forKey key: String) -> URL {
        return directory.appendingPathComponent(key).appendingPathExtension("json")
    }

    private func removeOldestFilesIfExceedingLimit() throws {
        let files = try fileManager.contentsOfDirectory(atPath: directory.path)
            .filter { $0.hasSuffix(".json") }
            .sorted { lhs, rhs in
                let lhsURL = directory.appendingPathComponent(lhs)
                let rhsURL = directory.appendingPathComponent(rhs)
                let lhsDate = (try? fileManager.attributesOfItem(atPath: lhsURL.path)[.creationDate] as? Date) ?? .distantPast
                let rhsDate = (try? fileManager.attributesOfItem(atPath: rhsURL.path)[.creationDate] as? Date) ?? .distantPast
                return lhsDate < rhsDate
            }

        if files.count >= maxStoredFiles {
            let filesToRemove = files.prefix(files.count - maxStoredFiles + 1)
            for fileName in filesToRemove {
                let url = directory.appendingPathComponent(fileName)
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    logError("Failed to remove the file exceeding the limit", error: error)
                }
            }
        }
    }
}
