//
//  HookSocketServer.swift
//  NotchTerminal
//
//  Receive-only Unix domain socket server for Claude Code hook events.
//  Fire-and-forget — no permission responses needed.
//

import Foundation

typealias HookEventHandler = @Sendable (HookEvent) -> Void

final class HookSocketServer: @unchecked Sendable {
    static let shared = HookSocketServer()
    static let socketPath = "/tmp/notch-terminal.sock"

    private var serverSocket: Int32 = -1
    private var acceptSource: DispatchSourceRead?
    private var eventHandler: HookEventHandler?
    private let queue = DispatchQueue(label: "com.sergiobehrends.NotchTerminal.socket", qos: .userInitiated)

    private init() {}

    func start(onEvent: @escaping HookEventHandler) {
        queue.async { [weak self] in
            self?.startServer(onEvent: onEvent)
        }
    }

    func stop() {
        acceptSource?.cancel()
        acceptSource = nil
        unlink(Self.socketPath)
    }

    // MARK: - Private

    private func startServer(onEvent: @escaping HookEventHandler) {
        guard serverSocket < 0 else { return }

        eventHandler = onEvent

        unlink(Self.socketPath)

        serverSocket = socket(AF_UNIX, SOCK_STREAM, 0)
        guard serverSocket >= 0 else { return }

        let flags = fcntl(serverSocket, F_GETFL)
        _ = fcntl(serverSocket, F_SETFL, flags | O_NONBLOCK)

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathMaxLen = MemoryLayout.size(ofValue: addr.sun_path)
        _ = Self.socketPath.withCString { ptr -> Int32 in
            withUnsafeMutablePointer(to: &addr.sun_path) { pathPtr -> Int32 in
                _ = strlcpy(UnsafeMutableRawPointer(pathPtr).assumingMemoryBound(to: CChar.self), ptr, pathMaxLen)
                return 0
            }
        }

        let bindResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(serverSocket, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }

        guard bindResult == 0 else {
            close(serverSocket)
            serverSocket = -1
            return
        }

        chmod(Self.socketPath, 0o600)

        guard listen(serverSocket, 10) == 0 else {
            close(serverSocket)
            serverSocket = -1
            return
        }

        acceptSource = DispatchSource.makeReadSource(fileDescriptor: serverSocket, queue: queue)
        acceptSource?.setEventHandler { [weak self] in self?.acceptConnection() }
        acceptSource?.setCancelHandler { [weak self] in
            if let fd = self?.serverSocket, fd >= 0 {
                close(fd)
                self?.serverSocket = -1
            }
        }
        acceptSource?.resume()
    }

    private func acceptConnection() {
        let clientSocket = accept(serverSocket, nil, nil)
        guard clientSocket >= 0 else { return }

        var nosigpipe: Int32 = 1
        setsockopt(clientSocket, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, socklen_t(MemoryLayout<Int32>.size))

        readAndDispatch(clientSocket)
    }

    private func readAndDispatch(_ clientSocket: Int32) {
        let flags = fcntl(clientSocket, F_GETFL)
        _ = fcntl(clientSocket, F_SETFL, flags | O_NONBLOCK)

        var allData = Data()
        var buffer = [UInt8](repeating: 0, count: 65536)
        var pollFd = pollfd(fd: clientSocket, events: Int16(POLLIN), revents: 0)

        let deadline = Date().addingTimeInterval(0.5)
        while Date() < deadline {
            let result = poll(&pollFd, 1, 50)
            if result > 0 && (pollFd.revents & Int16(POLLIN)) != 0 {
                let n = read(clientSocket, &buffer, buffer.count)
                if n > 0 {
                    allData.append(contentsOf: buffer[0..<n])
                } else if n == 0 {
                    break
                } else if errno != EAGAIN && errno != EWOULDBLOCK {
                    break
                }
            } else if result == 0 && !allData.isEmpty {
                break
            } else if result < 0 {
                break
            }
        }

        close(clientSocket)

        guard !allData.isEmpty,
              let event = try? JSONDecoder().decode(HookEvent.self, from: allData) else { return }

        eventHandler?(event)
    }
}
