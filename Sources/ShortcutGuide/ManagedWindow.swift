//
//  ManagedWindow.swift
//  
//
//  Created by Rachel on 2021/3/28.
//

import Cocoa

final class ManagedWindow {
    var window: NSWindow
    let closingSubscription: NotificationToken
    
    init(window: NSWindow, closingSubscription: NotificationToken) {
        self.window = window
        self.closingSubscription = closingSubscription
    }
}
