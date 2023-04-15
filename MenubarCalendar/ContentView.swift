//
//  ContentView.swift
//  MenubarCalendar
//
//  Created by listennn on 2021/9/24.
//

import SwiftUI
import ServiceManagement

struct RedButtonStyle: ButtonStyle {

    @State private var hoverActive = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8.0)
            .padding(.vertical, 4.0)
            .foregroundColor(Color.white)
            .background(configuration.isPressed || hoverActive ? Color(red: 0.8, green: 0.2, blue: 0.2) : Color.red)
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
            VStack(alignment: .leading){
                HStack(){
                    Button(action: { dateModel.minusMonth() }) {
                        Text("<")
                    }
                    Spacer()
                    Spacer()
                    Text(dateModel.month + " " + dateModel.year)
                        .font(.headline)
                        .fontWeight(.bold)
                        .font(.custom("Monaco", size: 12))
                    Spacer()
                    Button(action: { dateModel.goToToday() }) {
                        Text("Today")
                            .font(.custom("Monaco", size: 12))
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
                            .font(.custom("Monaco", size: 12))
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
                Spacer()
                Spacer()
                HStack(spacing: 24.0){
                    Spacer()
                    Spacer()
                    Button(action: {
                        NSApplication.shared.terminate(self)
                    }) {
                        Text("Quit")
                            .font(.custom("Monaco", size: 12))
                    }
                    .buttonStyle(RedButtonStyle())
                }
                .padding(.horizontal, 25.0)
                Spacer()
            }
            .padding(.all, 12.0)
        }
         .frame(width: 424.0, height: 324.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dateModel: DateModel())
    }
}
