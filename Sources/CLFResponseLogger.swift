//
//  CLFResponseLogger.swift
//  PerfectServerTest
//
//  Created by Dinesh Harjani on 07/06/2017.
//
//

import Foundation
import PerfectLib
import PerfectHTTP

public class CLFResponseLogger : NSObject {
    
    private enum Constants {
        static let UnknownIPAddress = "X.X.X.X"
        static let UnknownUser = "Ghost"
        static let UnkownBandwidthUsed = "0"
        static let UnknownUserAgent = "Unknown"
    }
    
    private let file: File
    private let dateFormatter: DateFormatter
    private let timeFormatter: DateFormatter
    
    public init(_ fileName: String) {
        self.file = File(fileName)
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd/MMM/yyyy"
        
        self.timeFormatter = DateFormatter()
        self.timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.timeFormatter.dateFormat = "HH:mm:ss ZZZZ"
        
        super.init()
    }
    
    public func log(response: HTTPResponse) {
        let request = response.request
        
        let ipAddress = request.connection.remoteAddress != nil ? request.connection.remoteAddress!.host : Constants.UnknownIPAddress
        let user = Constants.UnknownUser
        
        let requestDateAndTime = Date()
        let date = dateFormatter.string(from: requestDateAndTime)
        let time = timeFormatter.string(from: requestDateAndTime)
        
        let requestType = request.method.description
        let requestEndpoint = request.uri
        let requestProtocol = "HTTP/\(request.protocolVersion.0).\(request.protocolVersion.1)"
        
        let responseStatus = response.status.code
        let responseSize = response.header(.contentLength) != nil ? response.header(.contentLength)! : Constants.UnknownUserAgent

        let requestReferer = request.header(.referer) != nil ? String(describing: request.header(.referer)!) : Constants.UnknownUserAgent
        let requestUserAgent = String(describing: request.header(.userAgent)!)
        
        let loggedRequest = "\(ipAddress) - \(user) [\(date):\(time)] \"\(requestType) \(requestEndpoint) \(requestProtocol)\" \(responseStatus) \(responseSize) \"\(requestReferer)\" \"\(requestUserAgent)\""
        append(loggedRequest)
        print(loggedRequest)
    }
    
    public func append(_ newLine: String) {
        guard (file.exists) else {
            // New file
            do {
                try file.open(.write, permissions: .rwUserGroup)
                try file.write(string: newLine + "\n")
                file.close()
            } catch {
                print("Er - we couldn't write to \(file.realPath)")
            }
            
            return
        }
        
        do {
            try file.open(.append, permissions: .rwUserGroup)
            try file.write(string: newLine + "\n")
            file.close()
        } catch {
            print("Er - we couldn't append to \(file.realPath)")
        }
    }
}
