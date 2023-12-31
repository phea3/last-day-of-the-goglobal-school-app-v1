//
//  CustomDatePicker.swift
//  Goglobal School
//
//  Created by Leng Mouyngech on 25/8/22.
//
import SwiftUI
import Liquid

struct CustomDatePicker: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var Attendance: ListAttendanceViewModel = ListAttendanceViewModel()
    // Month update on arrow button clicks...
    @State var loading: Bool = true
    @State var currentMonth: Int = 0
    @State var studentId: String
    @Binding var currentDate: Date
    var sectionShiftId: String
    var prop: Properties
    var language: String
    var body: some View {
        
        VStack(spacing: 0){
            let days: [String] = ["អាទិត្យ","ចន្ទ","អង្គារ","ពុធ","ព្រហ","សុក្រ","សៅរ៍"]
            let englishdays: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
            
            HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
                VStack(alignment: .leading, spacing: prop.isiPhoneS ? 6 : prop.isiPhoneM ? 8 : 10) {
                    Text(extraDate()[0])
                        .font(.system(size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14))
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.custom("Bayon", size: prop.isiPhoneS ? 36 : prop.isiPhoneM ? 38 : 40, relativeTo: .title))
                }
                Spacer()
                Button {
                    withAnimation {
                        DispatchQueue.main.async{
                            if !Attendance.Attendances.isEmpty {
                                self.loading = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                currentMonth -= 1
                                Attendance.resetAttendance()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    Attendance.GetAllAttendance(studentId: studentId, sectionShiftId: self.sectionShiftId, currentDate: currentDate)
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Button {
                    withAnimation {
                        DispatchQueue.main.async{
                            if !Attendance.Attendances.isEmpty {
                                self.loading = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                currentMonth += 1
                                Attendance.resetAttendance()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                    Attendance.GetAllAttendance(studentId: studentId, sectionShiftId: self.sectionShiftId, currentDate: currentDate)
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding()
            
            // Day View...
            language == "en" ?
            
            HStack(spacing: 0){
                ForEach(englishdays, id: \.self){ day in
                    Text(day)
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .callout).bold())
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "Sun" ? .red : .gray)
                }
            }
            
            :
            
            HStack(spacing: 0){
                ForEach(days, id: \.self){ day in
                    Text(day)
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .callout).bold())
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "អាទិត្យ" ? .red : .gray)
                }
                
            }
            // Dates...
            //Lazy Grid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            ZStack{
                LazyVGrid(columns: columns, spacing: 0) {
                    
                    ForEach(extractDate()){ value in
                        
                        CardView(value: value)
                        
                    }
                }
                .padding(.top)
                if loading{
                    ZStack{
                        Color(colorScheme == .dark ? "Black" : "BG")
                            .opacity(1)
                        ZStack {
                            Liquid()
                                .frame(width: 240, height: 240)
                                .foregroundColor(.blue)
                                .opacity(0.3)


                            Liquid()
                                .frame(width: 220, height: 220)
                                .foregroundColor(.blue)
                                .opacity(0.6)

                            Liquid(samples: 5)
                                .frame(width: 200, height: 200)
                                .foregroundColor(.blue)
                            
                            Text("កំពុងភ្ជាប់".localizedLanguage(language: language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 36 : prop.isiPhoneM ? 38 : 40, relativeTo: .title))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
           
               
            VStack(spacing: prop.isiPhoneM ? 5 : prop.isiPhoneM ? 8 :  prop.isiPhoneL ? 10 : 12 ){
                guildline(text: "វត្តមាន", color: .blue)
                guildline(text: "មកយឺត", color: .green)
                guildline(text: "សុំច្បាប់", color: .yellow)
                guildline(text: "អវត្តមាន", color: .red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .padding(.bottom, 35)
        
        
        .onChange(of: currentMonth) { newValue in
            // Update Month...
            currentDate = getCurrentMont()
        }
        .onAppear(perform: {
            Attendance.GetAllAttendance(studentId: studentId, sectionShiftId: self.sectionShiftId, currentDate: currentDate)
        })
    }
    
    func guildline(text: String, color: Color)-> some View{
        HStack{
            Image(systemName: "square.fill")
                .font(.system(size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14))
                .foregroundColor(color)
            Text(text.localizedLanguage(language: self.language))
                .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .callout).bold())
                .foregroundColor(.gray)
        }
        .frame(maxWidth: 200, alignment: .leading)
    }
    @ViewBuilder
    func CardView(value: DateValue)-> some View{
        VStack{
            if value.day != -1 {
                
                if let attend = Attendance.Attendances.first(where: { attend in
                    return isSameDay(date1: convertDate(inputDate: attend.AttendanceDate), date2: value.date)
                })
                {
                    Text("\(value.day)")
                        .font(.system(size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16).bold())
                        .foregroundColor(attend.Status == "ABSENT" ? Color.white : attend.Status == "LATE" ? .white : attend.Status == "PRESENT" ? .white : attend.Status == "PERMISSION" ? .white : colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                        .background(
                            Circle()
                                .foregroundColor(attend.Status == "ABSENT" ? Color.red : attend.Status == "LATE" ? .green : attend.Status == "PRESENT" ? .blue : attend.Status == "PERMISSION" ? .yellow : .clear)
                        )
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                                self.loading = false
                            }
                        }
                }
                else
                {
                    Text("\(value.day)")
                        .font(.system(size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16).bold())
                        .foregroundColor(getSunday(dateofday: value.date) ? .red : isSameDay(date1: value.date, date2: currentDate) ? .primary : .primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding(.vertical, prop.isiPhoneS ? 7 : prop.isiPhoneM ? 8 : 9)
        .frame(height: 60, alignment: .center)
    }
    
    func convertDate(inputDate: String) -> Date{
        let isoDate = inputDate
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from:isoDate)!
        return date
    }
    func getSunday(dateofday: Date)->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let sun = dateFormatter.string(from: dateofday)
        return sun == "Sunday"
    }
    // checking date...
    func isSameDay(date1: Date, date2: Date)-> Bool {
        let calendar = NSCalendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // extracting year and month for display...
    func extraDate()->[String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMont()->Date{
        let calendar = NSCalendar.current
        // Getting Current Month Date...
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
        return currentMonth
    }
    
    func extractDate()->[DateValue]{
        let calendar = NSCalendar.current
        // Getting Current Month Date...
        let currentMonth = getCurrentMont()
        var days =  currentMonth.getAllDate().compactMap{ date -> DateValue in
            
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        //add offset days to get exact week day...
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}
