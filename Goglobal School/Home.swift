
import SwiftUI
import Alamofire
import ImageViewer
import LocalAuthentication
import ImageViewerRemote

struct Home: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appState = AppState.shared
    @StateObject var loginVM: LoginViewModel = LoginViewModel()
    @StateObject var addMobilUserToken: AddMobilUserToken = AddMobilUserToken()
    @StateObject var userProfile: MobileUserViewModel = MobileUserViewModel()
    @StateObject var academiclist: ListViewModel =  ListViewModel()
    @StateObject var AnnoucementList: AnnouncementViewModel = AnnouncementViewModel()
    @StateObject var AllClasses: ScheduleViewModel = ScheduleViewModel()
    @StateObject var Attendance: ListAttendanceViewModel = ListAttendanceViewModel()
    @StateObject var monitor = Monitor()
    @StateObject var student: ListStudentViewModel = ListStudentViewModel()
    init(){
        requestPushAuthorization();
        UITabBar.appearance().isHidden = true
    }
    @State var currentTab: Tab = .dashboard
    @State var animationFinished: Bool = false
    @State var animationStarted: Bool = false
    @State var gmail: String = (UserDefaults.standard.string(forKey: "Gmail") ?? "")
    @State var pass: String = (UserDefaults.standard.string(forKey: "Password") ?? "")
    @State var forget: Bool = false
    @State var isempty: Bool = false
    @State var isLoading: Bool = false
    @State var showContact: Bool = false
    @State var hideTab: Bool = false
    @State var showFlag: Bool = false
    @State var checkState: Bool = true
    @State var loggedIn: Bool = false
    @State var showingAlert: Bool = false
    @State var showingPassword: Bool = false
    @State var showingAlertUpdate = true
    @State var value: CGFloat = 0
    @State var hidefooter: Bool = false
    @State var image = Image("GoGlobalSchool")
    @State var newToken: String = ""
    @State var showTeacherImage: Bool = false
    @State var UrlImg: String = ""
    @State var isUnlocked = false
    @State var language = "km-KH"
    
    enum Field {
        case gmail, pass
    }
    @FocusState private var focusedField: Field?
    @State var focusEmail: Bool = false
    @State var focusPassword: Bool = false
    var body: some View {
        // MARK: Resposive App
        ResponsiveView { prop in
            // Login process
            ZStack{
                // MARK: background image
                ImageBackgroundSignIn()
                // perform login again if authentication is true, know gmail & password and we have token
                if (loginVM.isAuthenticated && (( gmail != "" && pass != "" ) && (loginVM.failLogin == false))){
                    
                    ZStack{
                        if !loggedIn{
                            // 3s progressing
                            progressingView(prop: prop, language: self.language, colorScheme: colorScheme)
                                .setBG(colorScheme: colorScheme)
                        }else{
                            MainView(prop: prop)
                        }
                    }
                    .onAppear{
                        //login mutation
                        loginVM.login(email: gmail, password: pass, checkState: checkState)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            // get active year
                            academiclist.activeAcademicYear()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if self.newToken != "" {
                                addMobilUserToken.addMobileUserToken(user: loginVM.userId, token: ApiTokenSingleton.shared.getFCMToken(), osType: "ios")
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            loggedIn = true
                        }
                    }
                    
                }else{
                    // login screen
                    ZStack{
                        
                        // login screen
                        LoginView(prop: prop)
                        
                        // change language
                        ChangeLanguage(prop: prop)
                            .padding()
                            .padding(.top,40)
                            .frame(maxWidth:.infinity, maxHeight: .infinity,alignment: .topTrailing)
                            .opacity( showFlag ? 0 : 1)
                    }
                }
                // animation loading
                FlashScreen(animationFinished: self.animationFinished, language: language, prop: prop)
                
                if showTeacherImage{
                    VStack {
                        ProgressView()
                    }
                    .padding(30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        ImageViewerRemote(imageURL: .constant(UrlImg), viewerShown: $showTeacherImage, disableCache: true, closeButtonTopRight: true)
                            .padding(.top)
                    )
                }
            }
            .alert(isPresented: .constant(VersionCheck.shared.newVersionAvailable ?? false)) {
                Alert(title: Text("សូមធ្វើការដំឡើង Version \(VersionCheck.shared.appStoreVersion ?? "") នៅក្នុង App Store!"), message: Text("Please update to version \(VersionCheck.shared.appStoreVersion ?? "") in the App Store!"), dismissButton: .default(Text("យល់ព្រម".localizedLanguage(language: self.language)), action: {
                    openURL(URL(string: VersionCheck.shared.appLinkToAppStore ?? "")!)
                    // 3s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        loginVM.signout()
                        Attendance.clearCache()
                        showFlag = false
                        UserDefaults.standard.removeObject(forKey: "DeviceToken")
                    }
                    UserDefaults.standard.removeObject(forKey: "Gmail")
                    UserDefaults.standard.removeObject(forKey: "Password")
                    UserDefaults.standard.removeObject(forKey: "isAuthenticated")
                }))
            }
            .alert("គ្មានអ៉ីនធើណេត".localizedLanguage(language: self.language), isPresented: .constant(!monitor.connected)) {
                Button("យល់ព្រម".localizedLanguage(language: self.language), role: .cancel) { }
            }
            .onAppear{
                // allow noti
                registerForNotifications()
                // check version in appstore
                VersionCheck.shared.checkAppStore()
                // check internet connection
                monitor.checkConnection()
                // get device's token
                DispatchQueue.main.asyncAfter(deadline:.now() + 1 ) {
                    self.newToken = ApiTokenSingleton.shared.token
                    //                    print("newtoke's phone: \(newToken)")
                }
                if !loginVM.isAuthenticated{
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .ignoresSafeArea(.container, edges: .leading)
    }
    
    @ViewBuilder
    //MARK: Main View or Tab View of Each Screen
    func MainView(prop: Properties)-> some View{
        ZStack{
            TabView(selection: $currentTab){
                Dashboard(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, bindingLanguage: $language,showTeacherImage: $showTeacherImage,UrlImg: $UrlImg, parentId: loginVM.userId, activeYear: academiclist.academicYearId, prop: prop, mobileUserId: loginVM.userprofileId, language: self.language)
                    .tag(Tab.dashboard)
                    .onChange(of: appState.actionofnoty) { newValue in
                        DispatchQueue.main.async {
                            appState.actionofnoty == "transportaion" ? (currentTab = .bus) : (currentTab = .dashboard)
                        }
                    }
                Education(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, bindingLanguage: $language,showTeacherImage: $showTeacherImage,UrlImg: $UrlImg, parentId: loginVM.userId, academicYearName: academiclist.khmerYear, language: self.language, prop: prop)
                    .tag(Tab.education)
                TransportationView(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, bindingLanguage: $language,showTeacherImage: $showTeacherImage,UrlImg: $UrlImg, parentId: loginVM.userId, academicYearName: academiclist.khmerYear, language: self.language, prop: prop)
                    .tag(Tab.bus)
                CalendarViewModel(userProfileImg: loginVM.userProfileImg, isLoading: $isLoading, bindingLanguage: $language, language: self.language, prop: prop, activeYear: academiclist.academicYearId)
                    .tag(Tab.bag)
                Profile(logout: loginVM, uploadImg: UpdateMobileUserProfileImg(), Loading: $isLoading, hideTab: $hideTab, checkState: $checkState, showFlag: $showFlag, bindingLanguage: $language, prop: prop, devicetoken: self.newToken, language: self.language)
                    .tag(Tab.book)
            }
            // MARK: Custom to Bar
            CustomTabBar(currentTab: $currentTab, prop: prop)
                .background(RoundedCorners(color: colorScheme == .dark ? .black :  .white, tl: 30, tr: 30, bl: 0, br: 0))
                .frame(maxWidth: prop.isLandscape || prop.isSplit ? 400 : prop.isiPad ? 400 : .infinity, maxHeight: .infinity, alignment: .bottom)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
                .opacity( hideTab ? 0 : animationStarted ? 1:0)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 1)){
                            animationStarted = true
                            self.showFlag = true
                        }
                    }
                }
        }
        .onAppear{
            ((AppState.shared.actionofnoty == "transportaion" ) && (AppState.shared.stu_id != nil)) ? (currentTab = .bus) : (currentTab = .dashboard)
        }
    }
    
    @ViewBuilder
    private func ChangeLanguage(prop: Properties)-> some View {
        HStack{
            Menu {
                Button {
                    self.language = "km-KH"
                } label: {
                    Text("ភាសាខ្មែរ")
                    Image("km")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                
                Button {
                    // Step #3
                    self.language = "en"
                } label: {
                    Text("English(US)")
                    Image("en")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                
            } label: {
                
                Image(language == "ch" ? "ch" : language == "km-KH" ? "km" : "en")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        Circle()
                            .stroke(.yellow, lineWidth: 1)
                    }
                    .padding(-5)
                    .frame(width: prop.isLandscape ? 14 : (prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : 20), alignment: .center)
            }
        }
    }
    
    // MARK: View of login Screen
    func LoginView(prop: Properties)-> some View{
        ZStack{
            Rectangle()
                .fill(colorScheme == .dark ? .black : .white)
                .frame(maxWidth:.infinity,maxHeight:.infinity)
            ImageBackgroundSignIn()
            VStack{
                Spacer()
                LogoGoglobal(prop:prop)
                    .opacity(prop.isLandscape && prop.isiPhone ? 0 : focusEmail && prop.isLandscape ? 0 : focusPassword && prop.isLandscape ? 0 : 1)
                
                VStack{
                    Text("ចូលប្រើកម្មវិធី".localizedLanguage(language: self.language))
                        .font(.custom("Bayon", size: prop.isiPhoneS ? 21 : prop.isiPhoneM ? 23 : prop.isiPhoneL ? 25 : 27, relativeTo: .largeTitle))
                        .foregroundColor(Color("ColorTitle"))
                }
                .opacity(prop.isLandscape && prop.isiPhone ? 0 : focusEmail && prop.isLandscape ? 0 : focusPassword && prop.isLandscape ? 0 : 1)
                
                if !hidefooter{
                    Spacer()
                }
                
                VStack(spacing: prop.isiPhoneS ? 14 : prop.isiPhoneM ? 16 : prop.isiPhoneL ? 18 : 20){
                    VStack(alignment: .leading, spacing: prop.isiPhoneS ? 4 : prop.isiPhoneM ? 6 : prop.isiPhoneL ? 8 : 10) {
                        Text("អ៉ីម៉ែល".localizedLanguage(language: self.language))
                            .font(.custom("Kantumruy", size: prop.isiPhoneS ? 15 : prop.isiPhoneM ? 17 : prop.isiPhoneL ? 19 : 21, relativeTo: .body))
                            .foregroundColor(.blue)
                        let binding = Binding<String>(get: {
                            self.gmail
                        }, set: {
                            self.gmail = $0.lowercased()
                        })
                        TextField("បញ្ចូលអ៉ីម៉ែល".localizedLanguage(language: self.language), text: binding, onEditingChanged: { (editingChanged) in
                            
                            if editingChanged {
                                focusEmail = true
                            } else {
                                focusEmail = false
                            }
                        })
                        .textContentType(.emailAddress)
                        .focused($focusedField, equals: .gmail)
                        .padding(prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : prop.isiPhoneL ? 16 : 18)
                        .cornerRadius(10)
                        .submitLabel(.next)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isempty ? .red:.blue.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: prop.isiPhoneS ? 4 : prop.isiPhoneM ? 6 : prop.isiPhoneL ? 8 : 10) {
                        Text("ពាក្យសម្ងាត់".localizedLanguage(language: self.language))
                            .font(.custom("Kantumruy", size: prop.isiPhoneS ? 15 : prop.isiPhoneM ? 17 : prop.isiPhoneL ? 19 : 21, relativeTo: .body))
                            .foregroundColor(.blue)
                        SecureTextFieldToggle(focusPassword: $focusPassword, text: $pass, isempty: isempty, prop: prop, language: self.language)
                            .textContentType(.password)
                            .focused($focusedField, equals: .pass)
                            .submitLabel(.return)
                    }
                    
                    VStack{
                        Button {
                            // login mutation
                            loginVM.login(email: gmail, password: pass, checkState: checkState)
                            self.isLoading = true
                            
                            if self.gmail.isEmpty || pass.isEmpty {
                                self.isempty = true
                                self.isLoading = false
                                
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 ) {
                                    if loginVM.failLogin{
                                        self.isLoading = false
                                        self.forget = true
                                        if loginVM.failLogin{
                                            showingAlert = true
                                        }
                                    }else{
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                                            if !loginVM.isAuthenticated{
                                                self.isLoading = false
                                                self.forget = true
                                                if loginVM.failLogin{
                                                    showingAlert = true
                                                }
                                            }else{
                                                if self.newToken != "" {
                                                    UserDefaults.standard.set(self.newToken, forKey: "DeviceToken")
                                                    addMobilUserToken.addMobileUserToken(user: loginVM.userId, token: ApiTokenSingleton.shared.getFCMToken(), osType: "ios")
                                                }
                                                if !loginVM.failLogin && loginVM.isAuthenticated{
                                                    DispatchQueue.main.async{
                                                        self.isLoading = false
                                                        self.forget = false
                                                        self.isempty = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            
                            if checkState{
                                UserDefaults.standard.set(self.gmail, forKey: "Gmail")
                                UserDefaults.standard.set(self.pass, forKey: "Password")
                            }
                            
                        } label: {
                            
                            Text("ចូលកម្មវិធី".localizedLanguage(language: self.language))
                                .font(.custom("Bayon", size: prop.isiPhoneS ? 16 : prop.isiPhoneM ? 18 : prop.isiPhoneL ? 22 : 24, relativeTo: .largeTitle))
                                .foregroundColor(.white)
                                .padding(prop.isiPhoneS ? 6 : prop.isiPhoneM ? 7 : prop.isiPhoneL ? 8 : 10)
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .cornerRadius(10)
                        }
                        .alert("គណនីរបស់លោកអ្នកមិនត្រឹមត្រូវទេ".localizedLanguage(language: self.language), isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { loginVM.failLogin = false }
                        }
                        
                        HStack(spacing: 0){
                            
                            Button(action:
                                    {
                                self.checkState.toggle()
                            }) {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: self.checkState ? "checkmark.square" : "square")
                                        .font(.system(size: 20))
                                        .padding(.bottom, 5)
                                    Text("ចងចាំពាក្យសម្ងាត់?".localizedLanguage(language: self.language))
                                        .font(.custom("Kantumruy", size: prop.isiPhoneS ? 11 : prop.isiPhoneM ? 13 : prop.isiPhoneL ? 15 : 17, relativeTo: .body))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                self.showContact = true
                            } label: {
                                Text("ភ្លេចពាក្យសម្ងាត់?".localizedLanguage(language: self.language))
                                    .font(.custom("Kantumruy", size: prop.isiPhoneS ? 11 : prop.isiPhoneM ? 13 : prop.isiPhoneL ? 15 : 17, relativeTo: .body))
                                    .foregroundColor(forget ? .red : .blue)
                            }
                            .sheet(isPresented: $showContact) {
                                SheetContact(prop: prop, language: self.language)
                            }
                            
                        }
                        .padding(.horizontal,2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top,5)
                }
                .frame(maxWidth: prop.isiPad ? 400 : prop.isiPhone ? 400 : .infinity )
                
                if !hidefooter{
                    if !((focusEmail && prop.isLandscape) && (focusPassword && prop.isLandscape)){
                        Spacer()
                    }
                }
                
                FooterImg(prop: prop)
                    .opacity(prop.isLandscape && prop.isiPhone ? 0 : focusEmail && prop.isLandscape ? 0 : focusPassword && prop.isLandscape ? 0 : 1)
                
            }
            .offset(y: -self.value)
            .animation(.spring(), value: self.value)
            .onAppear{
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                    let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = value.height
                    self.hidefooter = true
                    self.value = height
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                    self.hidefooter = false
                    self.value = 0
                }
            }
            .padding(prop.isiPhoneS ? 25: prop.isiPhoneM ? 30 : prop.isiPhoneL ? 35 : 40)
            
            if isLoading{
                progressingView(prop: prop, language: self.language, colorScheme: self.colorScheme)
            }
        }
        .onTapGesture {
            hideKeyboard()
            focusPassword = false
        }
    }
    
    // MARK: ASK USER FOR NOTIFICATIOON
    func requestPushAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("")
                //                Push Notification Allowed
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: GET DEVICE's token
    func registerForNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: TouchID & FaceID
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    // authenticated successfully
                    isUnlocked = true
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
            print("error")
        }
    }
}

struct SecureTextFieldToggle: View{
    @State var isSecureField: Bool = true
    @Binding var focusPassword: Bool
    @Binding var text: String
    var isempty: Bool
    var prop: Properties
    var language: String
    var body: some View{
        
        HStack{
            HStack{
                if isSecureField{
                    SecureField("បញ្ចូលពាក្យសម្ងាត់".localizedLanguage(language: self.language), text: $text) {
                        focusPassword = false
                        print("បញ្ចូលពាក្យសម្ងាត់")
                    }
                    .onTapGesture {
                        focusPassword = true
                    }
                }else{
                    let binding = Binding<String>(get: {
                        self.text
                    }, set: {
                        self.text = $0.lowercased()
                    })
                    TextField("បញ្ចូលពាក្យសម្ងាត់".localizedLanguage(language: self.language), text: binding) { (editingChanged) in
                        if editingChanged {
                            focusPassword = true
                        } else {
                            focusPassword = false
                        }
                    }
                }
            }
            
            Spacer()
            Button {
                self.isSecureField.toggle()
            } label: {
                Image(systemName: self.isSecureField ?  "eye.slash.fill" : "eye.fill" )
                    .foregroundColor(.blue)
            }
        }
        .padding(prop.isiPhoneS ? 12 : prop.isiPhoneM ? 14 : prop.isiPhoneL ? 16 : 18)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isempty ? .red : .blue .opacity(0.5), lineWidth: 1)
        )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


