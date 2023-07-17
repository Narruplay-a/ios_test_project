//
//  ContentView.swift
//  ios_test_project
//
//  Created by Adel Khaziakhmetov on 29.06.2023.
//

/*
* 1. Необходимо получить список продуктов
* 2. Отсортировать его по возрастанию поля newPrice
* 3. Отобразить список "Name NewPrice"
*
* Доп задания
* 1. Добавить возможность удаления элемента из списка
* 2. Написать тест для проверки загрузки продуктов, замерить длительность, использование памяти и процессора
* 3. Если список пустой, выбрасывать ошибку загрузки продуктов
*
* Request
* {{baseUrl}}/menu_product?companyUuid={{companyUuid}}
*
* base url https://food-delivery-api-bunbeauty.herokuapp.com/
* companyUuid 7416dba5-2825-4fe3-abfb-1494a5e2bf99
*
* Json
*  {
    "count": 82,
    "results": [
        {
            "uuid": "486af622-f0f9-4d16-ae8b-b052fedfd61a",
            "name": "Люля-кебаб из свинины",
            "newPrice": 200
        }
      ]
    }
* Response
* "uuid": "486af622-f0f9-4d16-ae8b-b052fedfd61a",
* "name": "Люля-кебаб из свинины",
* "newPrice": 200,
*
*
* */

import SwiftUI

struct ContentView: View {
    private let requestURL: URL = .init(string: "https://food-delivery-api-bunbeauty.herokuapp.com/menu_product")!
    
    var body: some View {
        VStack {
            
        }
        .padding()
    }
    
    func loadProducts(resultCallback: @escaping (Result<[ProductObject], Error>) -> Void) {
        let url = requestURL.appending(queryItems: [URLQueryItem(name: "companyUuid", value: "7416dba5-2825-4fe3-abfb-1494a5e2bf99")])
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            guard let data = data else {
                resultCallback(.failure(error ?? APIError.emptyData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let requestResult = try decoder.decode(ResultObject.self, from: data)
                
                resultCallback(.success(requestResult.results))
            } catch {
                resultCallback(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func loadProducts() async throws -> [ProductObject] {
        let url = requestURL.appending(queryItems: [URLQueryItem(name: "companyUuid", value: "7416dba5-2825-4fe3-abfb-1494a5e2bf99")])
        let urlRequest = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decoder = JSONDecoder()
        
        let requestResult = try decoder.decode(ResultObject.self, from: data)
        
        return requestResult.results
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ResultObject: Codable {
    let count   : Int
    let results : [ProductObject]
}

struct ProductObject: Codable, Identifiable {
    var id: String { uuid }
    let uuid        : String
    let name        : String
    let newPrice    : Int
}

enum APIError: Error {
    case emptyData
}
