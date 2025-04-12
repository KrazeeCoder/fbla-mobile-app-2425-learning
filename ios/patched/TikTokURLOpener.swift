import Foundation
import UIKit

public protocol TikTokURLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
    var keyWindow: UIWindow? { get }
    func isTikTokInstalled() -> Bool
}

public class TikTokURLOpenerImpl: TikTokURLOpener {
    
    public init() {}
    
    public func canOpenURL(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
    
    public func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: options, completionHandler: completion)
    }
    
    public var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: { $0.isKeyWindow })
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
