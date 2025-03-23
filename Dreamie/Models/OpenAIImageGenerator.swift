//
//  OpenAIImageGenerator.swift
//  Dreamie
//
//  Created by Christopher Woods on 3/23/25.
//
import Foundation
import OpenAI
import UIKit

class OpenAIImageGenerator: ObservableObject {
    func generateImageResults(description: String) async throws -> Data {
        let query = ImagesQuery(prompt: description, n: 1, size: ._1024)
        let result = try await OpenAI(apiToken: APIKey2.default).images(query: query)
        guard let urlString = result.data.first?.url,
                 let url = URL(string: urlString) else {
               throw URLError(.badURL)
           }
           
           // Download the image data.
           let (data, _) = try await URLSession.shared.data(from: url)
           
           
           
            return data
    }
 

}
