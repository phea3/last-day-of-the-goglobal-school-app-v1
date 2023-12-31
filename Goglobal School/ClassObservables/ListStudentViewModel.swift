//
//  ListStudentViewModel.swift
//  Goglobal School
//
//  Created by Leng Mouyngech on 25/8/22.
//
import Foundation

class ListStudentViewModel: ObservableObject {
    
    @Published var AllStudents: [StudentsViewModel] = []
    @Published var Error: Bool = false
    @Published var loading: Bool = true
    @Published var graphQLError: String = ""
    
    func StundentAmount(parentId: String){
        Network.shared.apollo.fetch(query: GetStudentsByParentsQuery(parentId: parentId)) { [weak self] result in
            switch result{
            case .success(let graphQLResult):
                if let graphQLError = graphQLResult.errors {
                    DispatchQueue.main.async {
                        self?.graphQLError = graphQLError.map{"\($0.message ?? "")"}.joined()
                    }
                }
                if let AllStudents = graphQLResult.data?.getStudentsByParents{
                    DispatchQueue.main.async {
                        self?.AllStudents = AllStudents.map(StudentsViewModel.init)
                        self?.loading = false
                    }
                }
            case.failure:
                DispatchQueue.main.async {
                    self?.Error = true
                }
            }
        }
    }
    func clearCache(){
        Network.shared.apollo.clearCache()
    }
    func resetStudent(){
        self.AllStudents = []
    }
}

struct StudentsViewModel {
    
    let student: GetStudentsByParentsQuery.Data.GetStudentsByParent?
    var Id: String {
        student?._id ?? ""
    }
    var Firstname: String{
        student?.firstName ?? ""
    }
    var Lastname: String{
        student?.lastName ?? ""
    }
    var EnglishName: String {
        student?.englishName ?? ""
    }
    var profileImage: String {
        student?.profileImg  ?? ""
    }
}

