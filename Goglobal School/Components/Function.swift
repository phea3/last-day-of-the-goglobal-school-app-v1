//
//  Function.swift
//  Goglobal School
//
//  Created by Leng Mouyngech on 25/8/22.
//

import Foundation
import SwiftUI
import Liquid
import ActivityIndicatorView

//Extending Date to get Current Month Dates...
extension Date{
    func getAllDate()->[Date]{
        let calendar = NSCalendar.current
        // Getting Start Date...
        let startDate = calendar.date(from: NSCalendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        // Getting Date...
        return range.compactMap{day -> Date in
            return calendar.date(byAdding: .day, value: day - 1 , to: startDate)!
        }
    }
}
extension View{
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    func getGradientOverlay() -> some View {
        LinearGradient(gradient:
                        Gradient(stops: [
                            .init(color: Color.white.opacity(0), location: 0),
                            .init(color: Color.white.opacity(0.9), location: 1.0)
                        ]),
                       startPoint: .top,
                       endPoint: .bottom
        )
    }
    func imageStuBG(prop: Properties)->some View{
        Image("DashboadBg")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: prop.isiPadPro ? 400 : prop.isiPadMini ? 450 : prop.isLandscape && prop.isiPad ? 600 : prop.isLandscape && prop.isiPhoneS ? 360 : prop.isLandscape && prop.isiPhoneM ? 370 : prop.isLandscape && prop.isiPhoneL ? 380 : 300)
    }
    func graduatedLogo(colorScheme: ColorScheme)->some View{
        Circle()
            .font(.system(size: 50))
            .frame(width: 49, height: 49, alignment: .center)
            .overlay(
                Image(systemName: "graduationcap.circle.fill")
                    .font(.system(size: 50))
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.white)
            )
    }
    func FooterImg(prop: Properties)-> some View{
        Image("Footer")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: prop.isLandscape ? 112 : prop.isLandscape && prop.isiPad ? 150 : prop.isiPad && !prop.isLandscape ? 140 : 110)
            .padding(.bottom, 40)
    }
    func LogoGoglobal(prop:Properties)->some View {
        Image("GoGlobalSchool")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: prop.isiPadMini ? 140 : prop.isiPadPro  ? 160 : prop.isiPhoneS ? 90 : prop.isiPhoneM ? 100 : prop.isiPhoneL ? 120 :  140)
        
    }
    func ImageBackgroundSignIn()->some View{
        Image("Background")
            .resizable()
            .ignoresSafeArea()
    }
    func gradientView(prop:Properties, gradient: Color) -> some View {
        gradient
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: prop.isLandscape ? 10 : 1)
    }
    func btnBackView(language: String,prop:Properties, title: String)->some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease") // set image here
                .font(.custom("Bayon", size: prop.isiPhoneS ? 14 : prop.isiPhoneM ? 16 : prop.isiPhoneL ? 18 : 18, relativeTo: .largeTitle))
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .padding(.bottom,prop.isiPhoneS ? 2 : prop.isiPhoneM ? 3 : prop.isiPhoneL ? 4 : 5)
            Text(title.localizedLanguage(language: language))
                .font(.custom("Bayon", size: prop.isiPhoneS ? 15 : prop.isiPhoneM ? 16 : prop.isiPhoneL ? 18 : 20, relativeTo: .body))
                .foregroundColor(Color("Blue"))
        }
    }
    func backButtonView(language:String, prop:Properties, barTitle: String) -> some View {
        HStack {
            Image(systemName: "chevron.backward") // set image here
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("Blue"))
            Text(barTitle.localizedLanguage(language: language))
                .textCase(.lowercase)
                .font(.custom("Bayon", size: prop.isiPhoneS ? 14 : prop.isiPhoneM ? 16 : prop.isiPhoneL ? 18 : 20, relativeTo: .body))
        }
    }
    func progressingView(prop:Properties, language: String, colorScheme: ColorScheme) -> some View {
        ZStack{
//            Liquid()
//                .frame(width: 140, height: 140)
//                .foregroundColor(.blue)
//                .opacity(0.3)
//            Liquid()
//                .frame(width: 120, height: 120)
//                .foregroundColor(.blue)
//                .opacity(0.6)
//            Liquid(samples: 5)
//               .frame(width: 100, height: 100)
//               .foregroundColor(.blue)
            Rectangle()
                .fill(colorScheme == .dark ? .clear : .white)
                .frame(width: 100, height: 100, alignment: .center)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
               
            VStack{
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                    .scaleEffect(prop.isiPhoneS ? 1 : prop.isiPhoneM ? 1: prop.isiPhoneL ? 1 : 1)
                ActivityIndicatorView(isVisible: .constant(true), type: .arcs(count: 3, lineWidth: 2))
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.blue)
                Text("កំពុងភ្ជាប់".localizedLanguage(language: language))
                    .foregroundColor(.blue)
            }
        }
        
    }
    func progressingView2(prop:Properties, language: String, colorScheme: ColorScheme) -> some View {
        VStack{
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(prop.isiPhoneS ? 1 : prop.isiPhoneM ? 1: prop.isiPhoneL ? 1 : 1)
            Text("កំពុងភ្ជាប់".localizedLanguage(language: language))
                .foregroundColor(.blue)
        }
    }
    @ViewBuilder func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
    @ViewBuilder func padOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
    func applyBG(colorScheme: ColorScheme)-> some View{
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color(colorScheme == .dark ? "Black" : "BG")
            )
    }
    
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity,alignment: .center)
    }
    
    func setBG(colorScheme: ColorScheme) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color(colorScheme == .dark ? "Black" : "BG")
            )
    }
    func setBackgroundRow(color: String, prop: Properties) -> some View {
        self
            .padding(prop.isiPhoneS ? 12 : prop.isiPhoneM ? 15 : prop.isiPhoneL ? 16 :  20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color(color))
            .cornerRadius(20)
    }
    
    func backgroundRemover()-> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .frame(maxHeight: .infinity, alignment: .leading)
    }
    
    func stuName(width: CGFloat)-> some View {
        self
        
    }
    
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

