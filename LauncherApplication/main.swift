//
//  main.swift
//  LauncherApplication
//
//  Created by listennn on 2021/10/5.
//

import Cocoa

let delegate = AutoLaunchAppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
