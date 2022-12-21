//
//  Grade.swift
//  Goglobal School
//
//  Created by Leng Mouyngech on 25/8/22.
//
import SwiftUI
import CoreImage.CIFilterBuiltins
import _MapKit_SwiftUI

struct Grade: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var locationManager = LocationManager()
    @StateObject var totalStu: GetTotalStudentViewModel = GetTotalStudentViewModel()
    @StateObject var enrollments: ListStudentViewModel = ListStudentViewModel()
    @StateObject var enrollment: EnrollmentViewModel = EnrollmentViewModel()
    @StateObject var studentqr: GetStudentCardByStudentIDViewModel = GetStudentCardByStudentIDViewModel()
    @StateObject var stuPickup: PickupViewModel = PickupViewModel()
    @State var ChoseTitle: String = ""
    @State var chose: Chose = .attendance
    @State var isShow: Bool = false
    @State private var selection: String? = nil
    @State var studentId: String
    @State var colorBlue: String = "LightBlue"
    @State var colorOrg: String = "LightOrange"
    @State var axcessPadding: CGFloat = 0
    @State var userProfileImg: String
    @State var classId: String = ""
    @State var academicYearId: String = ""
    @State var programId: String = ""
    @State var clasLoading: Bool = false
    @State var showqr: Bool = false
    @State var alert: Bool = false
    @State var successAfterPickup: Bool = false
    @State var earlyStage: String = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.360863317704524, longitude: 103.85711213340456), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    let annotations = [
        City(name: "Go Global School", coordinate: CLLocationCoordinate2D(latitude: 13.34777508421127, longitude: 103.8441745668323)),
    ]
    @Binding var showTeacherImage: Bool
    @Binding var UrlImg: String
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
    
    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    let schoolLocation = CLLocation(latitude: 13.34777508421127, longitude: 103.8441745668323)
    let gradient = Color("BG")
    let Student: String
    let StudentEnglishName: String
    var parentId: String
    var barTitle: String
    var studentID: String
    var language: String
    var prop: Properties
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        backButtonView(language: self.language, prop: prop, barTitle: barTitle)
    }
    }
    
    var body: some View {
        VStack(spacing: 0){
            Divider()
            if enrollment.enrollments.isEmpty{
                ZStack{
                    if clasLoading{
                        ProgressView()
                            .offset(y:30)
                    }else{
                        Text("មិនមានទិន្ន័យ!".localizedLanguage(language: self.language))
                            .foregroundColor(.blue)
                            .offset(y:30)
                    }
                }
                .onAppear{
                    self.clasLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.clasLoading = false
                    }
                }
            }else{
                VStack(spacing: 20){
                    List{
                        HStack{
                            Text("ថ្នាក់រៀន".localizedLanguage(language: self.language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16))
                            Text(language == "en" ? StudentEnglishName : Student)
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16))
                            Rectangle()
                                .frame(maxHeight: 1)
                        }
                        .foregroundColor(Color("Blue"))
                        .frame(width: .infinity, height: .infinity, alignment: .leading)
                        .backgroundRemover()
                        
                        ForEach(Array(enrollment.enrollments.enumerated()), id: \.element.EnrollmentId){ index, item in
                            VStack{
                                Choose( Grade: item.GradeName, Class: item.Classname, Year: item.AcademicYearName, Programme: item.Programme, chose: $chose, isShow: $isShow, ChoseTitle: $ChoseTitle, selection: $selection, ClassID: $classId, AcademicID: $academicYearId, ProgrammeID: $programId, classId: item.ClassId, gradeId: item.GradeId, academicYearId: item.AcademicId, programId: item.ProgrammeId, color: index % 2 == 0 ? colorOrg: colorBlue, earlyStage: item.ClassGroupNameEn, prop: prop, language: self.language, amongUs: "\(23)")
                                    .foregroundColor( index % 2 == 0 ?  Color("bodyOrange") : Color("bodyBlue"))
                                    .listRowInsets(EdgeInsets())
                            }
                            .backgroundRemover()
                            .onAppear{
                                DispatchQueue.main.async {
                                    self.earlyStage = item.ClassGroupNameEn
                                }
                            }
                        }
                        
                        if (self.earlyStage == "Early Childhood Education") || (self.earlyStage == "ECE") {
                            
                            HStack{
                                //                            Text("QR កូដ".localizedLanguage(language: self.language))
                                //                                .font(.custom("Bayon", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16))
                                Text("ទទួល".localizedLanguage(language: self.language))
                                    .font(.custom("Bayon", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16))
                                Text(language == "en" ? StudentEnglishName : Student)
                                    .font(.custom("Bayon", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16))
                                Rectangle()
                                    .frame(maxHeight: 1)
                            }
                            .foregroundColor(Color("Blue"))
                            .frame(width: .infinity, height: .infinity, alignment: .leading)
                            .backgroundRemover()
                            VStack{
                                let distance = schoolLocation.distance(from: CLLocation(latitude: locationManager.lastLocation?.coordinate.latitude ?? 0, longitude: locationManager.lastLocation?.coordinate.longitude ?? 0))
                                let d = distanceInMeters(distance: distance)
                                
                                Button {
                                    self.alert = !self.alert
                                } label: {
                                    HStack{
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 49, height: 49, alignment: .center)
                                            .overlay(
                                                Image("father-daughter-and-mother")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                            )
                                        
                                        Text("Please press here to pick up your child!".localizedLanguage(language: self.language))
                                            .listRowBackground(Color.yellow)
                                            .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                                            .foregroundColor(Color("bodyOrange"))
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color("LightOrange"))
                                    .cornerRadius(15)
                                }
                                .alert(isPresented: $alert){
                                    ( d == "1 metre" ) ||
                                    ( d == "2 metres" ) ||
                                    ( d == "3 metres" ) ||
                                    ( d == "4 metres" ) ||
                                    ( d == "5 metres" ) ||
                                    ( d == "10 metres" ) ||
                                    ( d == "15 metres" ) ||
                                    ( d == "20 metres" ) ||
                                    ( d == "25 metres" ) ||
                                    ( d == "30 metres" ) ||
                                    ( d == "35 metres" ) ||
                                    ( d == "40 metres" ) ||
                                    ( d == "45 metres" ) ||
                                    ( d == "50 metres") ||
                                    ( d == "55 metres" ) ?
                                    
                                    Alert(title: Text("Confirm Pick Up".localizedLanguage(language: self.language)),
                                          message: Text("Are you coming to pick up your child?".localizedLanguage(language: self.language)),
                                          primaryButton: .destructive( Text("យល់ព្រម".localizedLanguage(language: self.language))){
                                        stuPickup.pickup(stuId: studentqr.studentId, picked: true)
                                        DispatchQueue.main.async {
                                            self.successAfterPickup = stuPickup.success
                                        }
                                    },secondaryButton: .cancel(Text("ទេ".localizedLanguage(language: self.language))))
                                    :
                                    Alert(title:
                                            Text("\("You are".localizedLanguage(language: self.language)) (\(distanceInMeters(distance: distance))) \("away from the school and cannot pick the child up".localizedLanguage(language: self.language))".localizedLanguage(language: self.language)),
                                          dismissButton: .cancel(Text("យល់ព្រម".localizedLanguage(language: self.language)))
                                    )
                                }
                                
                                .alert("ជោគជ័យ", isPresented: $successAfterPickup) { }
                            }
                            .backgroundRemover()
                            
                        }
                        
                        //                        if #available(iOS 16.0, *) {
                        //                            QRView(stuName: Student, stuEngName: StudentEnglishName, studentQR: studentqr.studentId, prop: prop, language: self.language, showqr: $showqr)
                        //                                .backgroundRemover()
                        //                        } else {
                        // Fallback on earlier versions
                        //                        QrView(stuName: Student, stuEngName: StudentEnglishName, studentQR: studentqr.studentId, prop: prop, showqr: $showqr, language: self.language)
                        //                            .backgroundRemover()
                        //                        }
                        
                        
                        
                    }
                    .listStyle(GroupedListStyle())
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId,showTeacherImage: $showTeacherImage,UrlImg:$UrlImg, barTitle: ChoseTitle, prop: prop, classId: self.classId, academicYearId: self.academicYearId, programId: self.programId, language: self.language), tag: "attendance", selection: $selection) { EmptyView() }
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId,showTeacherImage: $showTeacherImage,UrlImg:$UrlImg, barTitle: ChoseTitle, prop: prop, classId: self.classId, academicYearId: self.academicYearId, programId: self.programId, language: self.language), tag: "absence", selection: $selection) { EmptyView() }
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId,showTeacherImage: $showTeacherImage,UrlImg:$UrlImg, barTitle: ChoseTitle, prop: prop, classId: self.classId, academicYearId: self.academicYearId, programId: self.programId, language: self.language), tag: "payment", selection: $selection) { EmptyView() }
                    NavigationLink(destination: Choosing(chose: chose, studentId: studentId,showTeacherImage: $showTeacherImage,UrlImg:$UrlImg, barTitle: ChoseTitle, prop: prop, classId: self.classId, academicYearId: self.academicYearId, programId: self.programId, language: self.language), tag: "score", selection: $selection) { EmptyView() }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .setBG(colorScheme: colorScheme)
        .onAppear(perform: {
            enrollments.StundentAmount(parentId: parentId)
            enrollment.getEnrollment(studentId: studentId)
            studentqr.getQRCode(stuID: studentId)
            totalStu.getTotal()
        })
        .navigationBarItems(leading: btnBack)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack{
                    AsyncImage(url: URL(string: "https://storage.go-globalschool.com/api\(userProfileImg)"), scale: 2){image in
                        
                        switch  image {
                            
                        case .empty:
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(width: prop.isLandscape ? 30 : (prop.isiPhoneS ? 24 : prop.isiPhoneM ? 24 : 24), alignment: .center)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .background(Color.black.opacity(0.2))
                                .overlay {
                                    Circle()
                                        .stroke(.orange, lineWidth: 1)
                                }
                                .clipShape(Circle())
                                .padding(-5)
                                .frame(width: prop.isLandscape ? 14 : (prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20), alignment: .center)
                        case .failure:
                            Image(systemName: "person.fill")
                                .padding(5)
                                .font(.system(size:  prop.isLandscape ? 22 : (prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : prop.isiPhoneL ? 16 : 18)))
                                .background(Color.white)
                                .overlay {
                                    Circle()
                                        .stroke(.orange, lineWidth: 1)
                                }
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: prop.isLandscape ? 14 : (prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20), alignment: .center)
                        @unknown default:
                            fatalError()
                        }
                    }
                }
            }
        }
        
    }
    func distanceInMeters(distance: CLLocationDistance)-> String{
        let df = MKDistanceFormatter()
        df.unitStyle = .full
        let prettyString = df.string(fromDistance: distance)
        return prettyString
    }
}
struct Choose: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var totalStu: GetTotalStudentViewModel = GetTotalStudentViewModel()
    @State var showsheet: Bool = false
    @State var Grade: String
    @State var Class: String
    @State var Year: String
    @State var Programme: String
    @Binding var chose: Chose
    @Binding var isShow: Bool
    @Binding var ChoseTitle: String
    @Binding var selection: String?
    @Binding var ClassID: String
    @Binding var AcademicID: String
    @Binding var ProgrammeID: String
    var classId: String
    var gradeId: String
    var academicYearId: String
    var programId: String
    var color: String
    var earlyStage: String
    var prop: Properties
    var language: String
    var amongUs: String
    var body: some View {
        
        HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
            Circle()
                .frame(width: 49, height: 49, alignment: .center)
                .overlay(
                    Image(systemName: "graduationcap.circle.fill")
                        .font(.system(size: 50))
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading){
                HStack(spacing: prop.isiPhoneS ? 3 : prop.isiPhoneM ? 4 : 5){
                    Text(Grade)
                        .listRowBackground(Color.yellow)
                        .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                    
                    Text("\(Class) |")
                        .listRowBackground(Color.yellow)
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                    Image("students")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14)
                    ForEach(totalStu.allTotal, id:\.ClassId){stu in
                        if stu.ClassId == classId && stu.GradId == gradeId{
                            Text("\(stu.Total)")
                                .listRowBackground(Color.yellow)
                                .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                        }
                    }
                    
                    Text("ន".localizedLanguage(language: self.language))
                        .listRowBackground(Color.yellow)
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                }
                Text(Programme)
                    .listRowBackground(Color.yellow)
                    .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
            }
        }
        .padding()
        .hLeading()
        .background(Color(colorScheme == .dark ? "Black" : color))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.orange, lineWidth: colorScheme == .dark ? 1 : 0)
        )
        .onAppear{
            totalStu.getTotal()
        }
        .onTapGesture {
            showsheet.toggle()
        }
        .halfSheet(showSheet: $showsheet) {
            // Half Sheet View...
            ZStack {
                Color( colorScheme == .dark ? "Black" : "White")
                    .frame(width: .infinity, height: .infinity, alignment: .leading)
                VStack(alignment: .leading,spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
                    Text("ជ្រើសរើស".localizedLanguage(language: self.language))
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20, relativeTo: .title2))
                        .foregroundColor(Color("Blue"))
                    TabButton(title: "កាលវិភាគសិក្សា", image: "calendar.badge.clock", chose: .attendance, selection: "attendance")
                        .buttonStyle(PlainButtonStyle())
                    TabButton(title: "វត្តមានសិស្ស", image: "checklist", chose: .absence, selection: "absence")
                        .buttonStyle(PlainButtonStyle())
                    TabButton(title: "ប្រវត្តិបង់ថ្លៃសិក្សា", image: "dollarsign.square.fill", chose: .payment, selection: "payment")
                        .buttonStyle(PlainButtonStyle())
                    if (earlyStage == "Early Childhood Education") || (earlyStage == "ECE") {
                        TabButton(title: "របាយការណ៍កុមារដ្ឋាន", image: "newspaper.fill", chose: .score, selection: "score")
                            .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(prop.isLandscape ? 50 : 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                Button {
                    showsheet = !showsheet
                } label: {
                    Image(systemName: "xmark.square.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                        .padding()
                        .opacity(prop.isLandscape ? 1:0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .buttonStyle(PlainButtonStyle())
                .padding(prop.isLandscape ? 20 : 0)
            }
            .ignoresSafeArea()
            
        } onEnd: {
            print("")
        }
    }
    @ViewBuilder
    func TabButton(title: String, image: String, chose: Chose, selection: String) -> some View{
        Button {
            self.ProgrammeID = self.programId
            self.AcademicID = self.academicYearId
            self.ClassID = self.classId
            self.chose = chose
            self.showsheet.toggle()
            self.isShow = true
            self.ChoseTitle = title
            self.selection = selection
            
        } label: {
            HStack(spacing: prop.isiPhoneS ? 6 : prop.isiPhoneM ? 8 : 10){
                Image(systemName: image)
                    .font(.title)
                Text(title.localizedLanguage(language: self.language))
                    .font(.custom("Bayon", size: 20, relativeTo: .title2))
            }
            .foregroundColor(Color("Blue"))
        }
    }
}
@available(iOS 16.0, *)
struct QRView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    @State var selectedDetent: PresentationDetent = .medium
    @State var detents: Set<PresentationDetent> = [.large, .medium]
    var stuName: String
    let stuEngName: String
    var studentQR: String
    var prop: Properties
    var language: String
    @Binding var showqr: Bool
    var body: some View{
        HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
            Image(systemName: "qrcode")
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(.white)
                        .frame(width: 50, height: 50)
                )
            Text("បង្ហាញ QR កូដ ទីនេះ!".localizedLanguage(language: self.language))
                .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                .foregroundColor(Color("bodyOrange"))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("LightOrange"))
        .cornerRadius(15)
        .onTapGesture {
            self.showqr = true
        }
        
        .sheet(isPresented: $showqr) {
            ZStack{
                Color.white
                    .frame(width: .infinity, height: .infinity)
                VStack{
                    HStack{
                        HStack(spacing: 0) {
                            Text(language == "en" ? stuEngName : stuName)
                                .font(.custom("Kantumruy", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16, relativeTo: .largeTitle))
                                .foregroundColor(Color("bodyBlue"))
                            Text("'s QR Code".localizedLanguage(language: self.language))
                                .font(.custom("Kantumruy", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16, relativeTo: .largeTitle))
                                .foregroundColor(Color("bodyBlue"))
                        }
                        
                        Spacer()
                        
                        Button {
                            selectedDetent = selectedDetent == .large ? .medium : .large
                        } label: {
                            Image(systemName: selectedDetent == .large ? "hand.point.down" : "hand.point.up")
                                .font(.system(size: 25))
                                .foregroundColor(.gray)
                        }
                        .presentationDetents(detents, selection: $selectedDetent)
                        .onChange(of: selectedDetent) { newValue in
                            if newValue == .large {
                                updateDetentsWithDelay()
                            } else {
                                detents = [.large, .medium]
                            }
                        }
                        
                        Button {
                            self.showqr = false
                        } label: {
                            Image(systemName: "multiply")
                                .font(.system(size: 25))
                                .foregroundColor(.gray)
                        }
                    }
                    if studentQR.isEmpty{
                        HStack{
                            Text("មិនមាន QR កូដ!".localizedLanguage(language: self.language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 20))
                        }
                        .foregroundColor(.red)
                        .frame(width: selectedDetent == .large ?  300 : 200 , height: selectedDetent == .large ?  300 : 200)
                        .border(.black)
                    }else{
                        Image(uiImage: generateQRCode(from: studentQR))
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: selectedDetent == .large ?  300 : 200 , height: selectedDetent == .large ?  300 : 200)
                    }
                    
                    HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 30))
                            .foregroundColor(Color("bodyBlue"))
                        VStack(alignment: .leading){
                            Text("សម្គាល់".localizedLanguage(language: self.language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                                .foregroundColor(Color("bodyBlue"))
                            Text("លោកអ្នកអាចស្កែនដើម្បីធ្វើការ Pickup កូន!".localizedLanguage(language: self.language))
                                .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                                .foregroundColor(Color("bodyBlue"))
                        }
                        
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("LightBlue"))
                    .cornerRadius(15)
                    Spacer()
                }
                .padding()
            }
            .ignoresSafeArea()
        }
    }
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    func updateDetentsWithDelay() {
        Task {
            //(1 second = 1_000_000_000 nanoseconds)
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard selectedDetent == .large else { return }
            detents = [.large]
        }
    }
}

struct QrView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var stuName: String
    let stuEngName: String
    var studentQR: String
    var prop: Properties
    @Binding var showqr: Bool
    var language: String
    var body: some View{
        Button {
            self.showqr = true
        } label: {
            
            HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
                Image(systemName: "qrcode")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    )
                Text("បង្ហាញ QR CODE ទីនេះ!".localizedLanguage(language: self.language))
                    .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                    .foregroundColor(Color("bodyOrange"))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("LightOrange"))
            .cornerRadius(15)
        }
        
        //        .onTapGesture {
        //            self.showqr = true
        //        }
        
        .sheet(isPresented: $showqr) {
            ZStack{
                Color.white
                    .frame(width: .infinity, height: .infinity)
                VStack{
                    HStack{
                        HStack(spacing: 0){
                            Text(language == "en" ? stuEngName : stuName)
                            Text("'s QR Code".localizedLanguage(language: self.language))
                        }
                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : 16, relativeTo: .largeTitle))
                        .foregroundColor(Color("bodyBlue"))
                        
                        Spacer()
                        Button {
                            self.showqr = false
                        } label: {
                            Image(systemName: "multiply")
                                .font(.system(size: 25))
                                .foregroundColor(.gray)
                        }
                    }
                    if studentQR.isEmpty{
                        HStack{
                            Text("មិនមាន QR Code!".localizedLanguage(language: self.language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 20))
                        }
                        .foregroundColor(.red)
                        .frame(width: 300, height: 300)
                        .border(.black)
                    }else{
                        Image(uiImage: generateQRCode(from: studentQR))
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                    
                    
                    HStack(spacing: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20){
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 30))
                            .foregroundColor(Color("bodyBlue"))
                        VStack(alignment: .leading){
                            Text("សម្គាល់".localizedLanguage(language: self.language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                                .foregroundColor(Color("bodyBlue"))
                            Text("លោកអ្នកអាចស្កែនដើម្បីធ្វើការ Pickup កូន!".localizedLanguage(language: self.language))
                                .font(.custom("Kantumruy", size: prop.isiPhoneS ? 10 : prop.isiPhoneM ? 12 : 14, relativeTo: .largeTitle))
                                .foregroundColor(Color("bodyBlue"))
                        }
                        
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("LightBlue"))
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding()
            }
            .ignoresSafeArea()
        }
    }
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
struct Grade_Previews: PreviewProvider {
    static var previews: some View {
        
        let prop = Properties(isLandscape: false, isiPad: false, isiPhone: false, isiPhoneS: false, isiPhoneM: false, isiPhoneL: false,isiPadMini: false,isiPadPro: false, isSplit: false, size: CGSize(width:  0, height:  0))
        Grade(studentId: "", userProfileImg: "",showTeacherImage: .constant(false),UrlImg: .constant(""), Student: "", StudentEnglishName: "", parentId: "", barTitle: "",studentID: "", language: "em", prop: prop)
    }
}

struct ResultView: View {
    var choice: String
    
    var body: some View {
        Text("You chose \(choice)")
    }
}
