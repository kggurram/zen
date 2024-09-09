//
//  OpenAIService.swift
//  ZenCheck
//
//  Created by Karthik Gurram on 2024-08-18.
//

import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let text: String
    }
}

func fetchTaskSummary(tasks: [Task], completion: @escaping (String) -> Void) {
    let apiKey = "your-openai-api-key"
    let endpoint = "https://api.openai.com/v1/completions"
    
    let prompt = "Provide a summary of the following tasks: \(tasks.map { $0.title }.joined(separator: ", "))."
    
    let parameters: [String: Any] = [
        "model": "text-davinci-003", // or the model you want to use
        "prompt": prompt,
        "max_tokens": 100,
        "temperature": 0.7
    ]
    
    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion("Error fetching summary.")
            return
        }
        
        if let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
            completion(response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No summary available.")
        } else {
            completion("Failed to decode response.")
        }
    }.resume()
}
