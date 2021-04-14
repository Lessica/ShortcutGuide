//
//  NotificationToken.swift
//  
//
//  Created by Rachel on 2021/3/28.
//

import Cocoa

final class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let notificationToken: Any
    let eventMonitors: [Any]?
    
    init(
        notificationCenter: NotificationCenter = .default,
        notificationToken token: Any,
        eventMonitors monitors: [Any]?
    ) {
        self.notificationCenter = notificationCenter
        self.notificationToken = token
        self.eventMonitors = monitors
    }
    
    deinit {
        notificationCenter.removeObserver(notificationToken)
        eventMonitors?.forEach({ NSEvent.removeMonitor($0) })
    }
}

extension NotificationCenter {
    func observe(
        name: NSNotification.Name?,
        object obj: Any?,
        eventMonitors monitors: [Any]?,
        queue: OperationQueue? = nil,
        using block: @escaping (Notification) -> ()
    )
    -> NotificationToken
    {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, notificationToken: token, eventMonitors: monitors)
    }
}

