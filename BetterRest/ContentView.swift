//
//  ContentView.swift
//  BetterRest
//
//  Created by Student on 11/15/24.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp:Date = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var timeToBed:Date = defaultBedTime

    func shortenDate(convertDate: Date) -> String{
        let dateToString = DateFormatter()
        dateToString.dateFormat = "HH:mm"
        return dateToString.string(from: convertDate)
    }

   static var defaultBedTime: Date {
       var components = DateComponents()
       components.hour = -1
       components.minute = 0
       return Calendar.current.date(from: components) ?? .now
    }

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

        var body: some View {
            NavigationStack{
                List {
                    Section (header: Text("When do you want to wake up?")){
                        DatePicker("Please Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .onChange(of: wakeUp){newValue in
                                calculateBedtime()
                            }
                            .labelsHidden()
                    }
                    Section (header: Text("Desired amount of sleep")){
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            .onChange(of: sleepAmount){newValue in
                                calculateBedtime()
                            }
                    }
                    Section (header: Text("Daily coffee intake")){
                        Picker("", selection: $coffeeAmount){
                            ForEach(0...20, id: \.self){
                                number in
                                if number == 1 {
                                    Text("^[\(number) cup](inflect: true)")
                                } else {
                                    Text("\(number) cups")
                                }
                            }
                        }
                    }
                    .onChange(of: coffeeAmount){newValue in
                        calculateBedtime()
                    }
                    VStack {
                        Text("Your Bedtime is \(shortenDate(convertDate: timeToBed))")
                            .font(.title2)
                            .bold()
                            .padding([.top, .bottom], 30)
                    }
                }
                .navigationTitle("BetterRest")
            }
        }
    func calculateBedtime() {
        if coffeeAmount == 0 {
            timeToBed = Calendar.current.date(byAdding: .minute, value: -Int(sleepAmount * 60), to: wakeUp) ?? Date.now
        } else {
            do {
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 6
                let minute = (components.minute ?? 0) * 60
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

                timeToBed = wakeUp - prediction.actualSleep

            } catch {
                alertTitle = "Error"
                alertMessage = "Sorry, there was a problem calculating your bedtime."
            }
                    showingAlert = true
        }
    }
 }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }

}
