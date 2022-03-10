import Foundation
import Vapor
import NIO

public enum ClientConfig {
    case udp(address: String, port: Int)
    case uds(path: String)
}

// A write-only Socket client
public class SocketWriteClient {
    
    public let eventLoopGroup: EventLoopGroup
    private let remoteAddress: SocketAddress
    private var channel: Channel?
    private let config: ClientConfig
    
    public init(on eventLoopGroup: EventLoopGroup, clientConfig: ClientConfig) throws {
        self.eventLoopGroup = eventLoopGroup
        self.config = clientConfig
    
        switch clientConfig {
        case .udp(let host, let sendPort):
            remoteAddress = try SocketAddress.makeAddressResolvingHost(host, port: sendPort)
        case .uds(let sendPath):
            remoteAddress = try SocketAddress(unixDomainSocketPath: sendPath)
        }
    }
    
    func send(payload: String) {
        
        if let chan = self.channel {
            let buffer = chan.allocator.buffer(string: payload)
            let envolope = AddressedEnvelope<ByteBuffer>(remoteAddress: remoteAddress, data: buffer)
            chan.writeAndFlush(envolope, promise: nil)
            return
        }
        let bootstrap = DatagramBootstrap(group: eventLoopGroup)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(SocketHandler(remoteAddress: self.remoteAddress, payload: payload))
        }
        
        switch config {
        case .udp:
            _ = bootstrap.bind(host: "0.0.0.0", port: 0).map { channel in
                self.channel = channel
            }
        case .uds:
            _ = bootstrap.bind(unixDomainSocketPath: "/tmp/swiftdogstatsdnoopsock", cleanupExistingSocketFile: true).map { channel in
                self.channel = channel
            }
        }
    }
}

private final class SocketHandler: ChannelInboundHandler {
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    
    private let remoteAddress: SocketAddress
    private let payload: String
    
    init(remoteAddress: SocketAddress, payload: String) {
        self.remoteAddress = remoteAddress
        self.payload = payload
    }
    
    public func channelActive(context: ChannelHandlerContext) {
        let buffer = context.channel.allocator.buffer(string: payload)
        let envolope = AddressedEnvelope<ByteBuffer>(remoteAddress: remoteAddress, data: buffer)
        context.writeAndFlush(self.wrapOutboundOut(envolope), promise: nil)
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {}
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)
        context.close(promise: nil)
    }
}
