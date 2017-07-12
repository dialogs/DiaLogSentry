
import DialExt
import Sentry

/**
 Run sentry.
 Call this method in your logger configuration or just in the applicationDidFinishLaunching method.
 */
@discardableResult public func runSentry(dsn: String) -> Bool {
    do {
        Client.shared = try Client(dsn: dsn)
    }
    catch {
        DESLog("Fail to initiate Sentry")
        DELog("Sentry failed: \(error)", level: .fault)
        return false
    }
    
    DELogger.shared.services.append(SentryLogService())
    return true
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

