
import DialExt


public func runSentry(dsn: String) {
    do {
        Client.shared = try Client(dsn: "https://d4f8f2c5c45f4ca09e81fda0758e63bb:105123ba02414707bfcbc990a214a00e@sentry.transmit.im/11")
    }
    catch {
        AppSLog(message: "Fail to initiate Sentry")
        AppLog(message: "Sentry failed: \(error)", level: .fault)
        exit(0)
    }
    
    DELogger.shared.services.append(SentryLogService())
}


public class SentryLogService: DELogService {
    
    public func log(_ message: String, subsystem: DELogger.Subsystem, tag: String, level: DELogger.Level, info: DELogger.Info?, logger: DELogger) {
        switch level {
        case .error: fallthrough
        case .fault:
            Client.shared?.snapshotStacktrace {
                let event = Event(level: .debug)
                event.message = message
                Client.shared?.send(event: event, completion: nil)
            }
            
        default:
            SentryLog.log(withMessage: message, andLevel: .verbose)
        }
    }
}

