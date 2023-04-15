//
//  AppDelegate.swift
//  MenubarCalendar
//
//  Created by listennn on 2021/9/24.
//

import Cocoa
import SwiftUI
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var timer: Timer!
    @ObservedObject var dateModel = DateModel()
//    @State private var autoLogin = true {
//        didSet {
//            SMLoginItemSetEnabled("com.listennn.MenubarCalendar" as CFString, autoLogin)
//        }
//    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(dateModel: dateModel)
        
        // Create the window and set the content view.
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 424, height: 324)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        self.popover = popover
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))


        if let button = self.statusBarItem.button {
            button.title = self.dateModel.formattedToday
            button.frame = CGRect.init(x: 0.0, y: 0.5, width: button.frame.width, height: button.frame.height)
            button.font = NSFont(name: "Monaco", size: 12.0)
//            button.image = NSImage(named: "Icon")
            button.action = #selector(togglePopover(_:))
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getDate), userInfo: nil, repeats: true)
    }

    @objc func getDate() {
        dateModel.setDate()
        if let button = self.statusBarItem.button {
            button.title = self.dateModel.formattedToday
        }
    }
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.dateModel.goToToday()
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}
