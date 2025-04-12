import Foundation
import UIKit

public protocol TikTokURLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
    var keyWindow: UIWindow? { get }
    func isTikTokInstalled() -> Bool
}

public extension TikTokURLOpener {
    // Optional overload for easier usage
    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        open(url, options: [:], completionHandler: completion)
    }
}

public class TikTokURLOpenerImpl: TikTokURLOpener {
    
    public init() {}
    
    public func canOpenURL(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }

    public func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: options, completionHandler: completion)
    }

    public var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    public func isTikTokInstalled() -> Bool {
        for scheme in TikTokInfo.schemes {
            if let schemeURL = URL(string: "\(scheme)://") {
                if canOpenURL(schemeURL) {
                    return true
                }
            }
        }
        return false
    }
}
