
import DialExt

/**
 Run sentry.
 Call this method in your logger configuration or just in the applicationDidFinishLaunching method.
 */
public func runSentry(dsn: String) {
    do {
        Client.shared = try Client(dsn: dsn)
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

