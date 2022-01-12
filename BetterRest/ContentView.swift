//
//  ContentView.swift
//  BetterRest
//
//  Created by Dante Cesa on 1/11/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp: Date = defaultWakeTime
    @State private var sleepAmount: Double = 8.0
    @State private var coffeeAmount: Int = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 32
        return Calendar.current.date(from: components) ?? Date.now
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).frame(maxWidth: .infinity, alignment: .center)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                } header: {
                    Text("What time do you have to wake up?")
                }
                Section {
                    Stepper(calculateMinuteText(forTime: sleepAmount), value: $sleepAmount, in: 4...12, step: 0.25).frame(alignment: .center)
                } header: {
                    Text("How many hours of sleep?")
                }
                
                Section {
                    Stepper(coffeePrinter(), value: $coffeeAmount, in: 0...20)
                } header: {
                    Text("Tell us about your coffee intake")
                }
                
                Section {
                    VStack {
                        Text("You should go to bed at…").padding(5)
                        Text(calculateBedTime())
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } header: {
                    Text("Recommendation")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func coffeePrinter() -> String {
        switch coffeeAmount {
        case 0:
            return "None"
        case 1:
            return "☕️ 1 cup"
        default:
            return "☕️ \(coffeeAmount) cups"
        }
    }
    
    func calculateMinuteText(forTime: Double) -> String {
        var output = ""
        let splitTimeString = String(sleepAmount).split(separator: ".")
        let hours = "\(splitTimeString[0]) hours "
        let minutes = Int(splitTimeString[1])
        
        switch minutes {
        case 25:
            output = hours + "15 min"
        case 5:
            output = hours + "30 min"
        case 75:
            output = hours + "45 min"
        default:
            output = hours
        }
        
        return output
    }
    
    func calculateBedTime() -> String {
        var output: String = ""
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourInSeconds + minutesInSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
        
            output = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            output = "There was an error when calculating sleep time."
        }
        
        return output
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
