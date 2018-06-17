//
//  ViewController.swift
//  TestAppSwift1
//
//  Created by netease163 on 2018/6/17.
//  Copyright © 2018年 netease163. All rights reserved.
//

import UIKit
/*
    * 该情况是服务器返回的json数据，类型放在一个可变数组里面
    类似下面：
     {
         "points": ["KSQL", "KWVI", "KYYU"],
         "KSQL": {
             "code": "KSQL",
             "name": "San Carlos Airport"
         },
         "KWVI": {
             "code": "KWVI",
             "name": "Watsonville Municipal Airport"
         },
         "KYYU": {
             "code": "YangYuren",
             "name": "Test is A Test"
         }
     }

 */
struct Airport: Decodable {
    var code: String
    var name: String
}
struct Route : Decodable{
    var points: [Airport]
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int? {
            return nil
        }
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        init?(intValue: Int) {
            return nil
        }
        static let points = CodingKeys(stringValue: "points")!
    }
    init(from coder: Decoder) throws {
        let container = try coder.container(keyedBy: CodingKeys.self)
        var points: [Airport] = []
        let codes = try container.decode([String].self,forKey: .points)
        for code in codes {
            let key = CodingKeys(stringValue: code)!
            let airport = try container.decode(Airport.self,forKey: key)
            points.append(airport)
        }
        self.points = points

    }
}
/*
    *对应json数据2里面解析
 */
enum Fuel: String, Decodable {
    case jetA = "Jet A"
    case jetB = "Jet B"
    case oneHundredLowLead = "100LL"
}
struct AmericanFuelPrice:Decodable{
    let fuel: Fuel
    // 美元/加仑
    let price: Double
}
struct CanadianFuelPrice:Decodable{
    let type: Fuel
    // 加元/升
    let price: Double
}
protocol FuelPrice {
    var type: Fuel { get }
    var pricePerLiter: Double { get }
    var currency: String { get }
}
extension AmericanFuelPrice: FuelPrice {
    var type: Fuel {
        return self.fuel
    }
    var pricePerLiter: Double {
        return self.price / 3.78541
    }
    var currency: String {
        return "USD"
    }
}
extension CanadianFuelPrice: FuelPrice {
    var pricePerLiter: Double {
        return self.price
    }
    var currency: String {
        return "CAD"
    }
}
struct CanadaList : Decodable{
    var fuels : [CanadianFuelPrice]
}
class ViewController: UIViewController {
    func test1(){
        let url = Bundle.main.url(forResource: "test", withExtension: "json") ?? URL(fileURLWithPath: "....")
        do{
            let data = try Data(contentsOf: url)
            let decodr = JSONDecoder()
            let yang = try decodr.decode(Route.self, from: data)
            if let name = yang.points.first?.name{
                print(name)
            }
        }catch let error{
            print(error)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do{
            let decoder = JSONDecoder()
            let url = Bundle.main.url(forResource: "test2", withExtension: "json") ?? URL(fileURLWithPath: "....")
            let json = try Data(contentsOf: url)
            let list = try decoder.decode(CanadaList.self, from: json)
            print(list)
        }catch let error{
            print(error)
        }
    }
}

