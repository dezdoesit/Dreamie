////
////  ImageGenTestView.swift
////  Dreamie
////
////  Created by Christopher Woods on 3/23/25.
////
//
//
//import SwiftUI
//import GoogleGenerativeAI
//

//struct ImageGenTestView: View {
//    
//    @State var prompt: String = ""
//    @State var imageResults: Image = Image("")
//    @State var openSheet = false
//    @State var         aiResponse: String = ""
//    @ObservedObject var openAIVM = OpenAIImageGenerator()
//    
//    let model = GenerativeModel(name: "gemini-2.0-flash", apiKey: APIKey.default)
//    
////    @ObservedObject var genAI: Gemeni = Gemeni()
//    
//    var body: some View {
//        
//        VStack {
//            TextField("Type in a test prompt", text: $prompt)
//            
//            Button(action: {
//                sendMessage()
//                
//                Task {
//                      do {
//                         try await imageResults = Image(uiImage: openAIVM.generateImageResults(description: prompt))
//  
//                      } catch {
//                          print("error \(error.localizedDescription)" )
//                      }
//                      openSheet = true
//                  }
//                print("Submit pressed")
//            }, label: {
//                Text("submit")
//            })
//            
//            Text(aiResponse)
//            
//            .sheet(isPresented: $openSheet) {
//                VStack {
//                    imageResults
//                    
//                }
//                
//                
//            }
//
//            
//            
//        }
//    }
//    
//    func sendMessage() {
//        aiResponse = ""
//            
//         Task {
//                do {
//                    let response = try await model.generateContent(prompt)
//                    
//                    guard let text = response.text else  {
//                        prompt = "Sorry, I could not process that.\nPlease try again."
//                        return
//                    }
//                    
//                    prompt = ""
//                    aiResponse = text
//                    
//                } catch {
//                    aiResponse = "Something went wrong!\n\(error.localizedDescription)"
//                }
//            }
//        }
//}
//
//#Preview {
//    ImageGenTestView()
//}
