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
    
    @State private var alertTitle: String = ""
    @State private var alertText: String = ""
    @State private var showAlert: Bool = false

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
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden().datePickerStyle(.wheel)
                } header: {
                    Text("What time do you have to wake up?")
                }
                Section {
                    Stepper(calculateMinuteText(forTime: sleepAmount), value: $sleepAmount, in: 4...12, step: 0.25).frame(alignment: .center)
                } header: {
                    Text("How many hours of sleep?")
                }
                
                Section {
                    Stepper(coffeeAmount == 1 ? "☕️ 1 cup" :  "☕️ \(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                } header: {
                    Text("Tell us about your coffee intake")
                }
                
                /*Section {
                    VStack {
                        Text("You should go to bed at…").padding(5)
                        Text(calculateBedTime()).font(.largeTitle).frame(maxWidth: .infinity, alignment: .center)
                    }
                } header: {
                    Text("Recommendation")
                }*/
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertText)
            }
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
    
    func calculateBedTime() {//} -> String {
        //var output: String = ""
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourInSeconds + minutesInSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal sleep time is…"
            alertText = sleepTime.formatted(date: .omitted, time: .shortened)
            //output = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Something went wrong"
            alertText = "There was an error when calculating sleep time."
        }
        
        showAlert = true
        //return output
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
