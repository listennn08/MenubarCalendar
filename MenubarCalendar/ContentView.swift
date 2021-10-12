//
//  ContentView.swift
//  MenubarCalendar
//
//  Created by listennn on 2021/9/24.
//

import SwiftUI
import ServiceManagement

struct BlueButtonStyle: ButtonStyle {

    @State private var hoverActive = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8.0)
            .padding(.vertical, 4.0)
            .foregroundColor(Color.white)
            .background(configuration.isPressed || hoverActive ? Color(red: 100, green: 1, blue: 1) : Color.red)
            .cornerRadius(4.0)
            .onHover{ hovering in
                hoverActive = hovering
            }
    }
}


struct ContentView: View {
    
    @ObservedObject var dateModel: DateModel
    @State private var launchAtLogin = true {
        didSet {
            SMLoginItemSetEnabled(
                Constants.helpBundleID as CFString,
                launchAtLogin
            )
        }
    }
    
    private struct Constants {
        static let helpBundleID = "com.listennn.LauncherApplication"
    }

    var body: some View {
        NavigationView{
            VStack{
                HStack(alignment: .center){
                    Button(action: { dateModel.minusMonth() }) {
                        Text("<")
                    }
                    Spacer()
                    Spacer()
                    Text(dateModel.month + " " + dateModel.year)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { dateModel.goToToday() }) {
                        Text("Today")
                    }
                    Button(action: { dateModel.addMonth() }) {
                        Text(">")
                    }
                }
                .padding(.horizontal)
                .frame(width: 400.0, height: 50.0)

                HStack(spacing: 24.0) {
                    ForEach (dateModel.weeks, id: \.self) { week in
                        Text(week.capitalized)
                            .fontWeight(.bold)
                            .frame(width: 32.0)
                            .foregroundColor(
                                week == "sat" || week == "sun" ? Color.red : nil
                            )
                    }
                }
                .padding([.leading, .bottom, .trailing])
                
                GridView(columns: 7, list: dateModel.calendarList) { item in
                    Text(item.date)
                        .fontWeight(.bold)
                        .foregroundColor(
                            item.isCurrentDate
                                ? Color.red
                                : item.isCurrentMonth
                                    ? nil
                                    : Color.gray
                        )
                        .font(.custom("Monaco", size: 12))
                        
                }
                
                HStack(spacing: 24.0){
//                    Toggle(isOn: $launchAtLogin) {
//                        Text("Launch at Login")
//                    }
                    Spacer()
                    Button(action: {
                        NSApplication.shared.terminate(self)
                    }) {
                        Text("Quit")
                            .font(.custom("Monaco", size: 12))
                    }
                    .buttonStyle(BlueButtonStyle())
                }
                .padding(.all)
            }
        }
        .padding(.all)
        .frame(width: 400.0, height: 300.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dateModel: DateModel())
    }
}
