//
//  PoiSearchViewController.swift
//  RxSwiftStudy
//
//  Created by Popeye Lau on 16/6/4.
//  Copyright © 2016年 FavourFree. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON
import RxDataSources

struct Suggestion {
    var city: String
    var district: String
    var suggest: String
}

class PoiSearchViewController: UIViewController {

    @IBOutlet weak var keywordsField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let dataSource = Variable([Suggestion]())
    let identifier = "poi_result_cell"

    override func viewDidLoad() {


        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        //监听文本录入
        keywordsField.rx_text
            .filter{ $0.characters.count > 0 }
            .throttle(1.0, scheduler: MainScheduler.instance)
            .flatMap { self.querySuggestion($0) }
            .subscribe(
                onNext: { (result) in
                    self.dataSource.value = result
                    result.forEach({ item in
                        print("\(item.city) - \(item.district) - \(item.suggest)")
                    })
                },
                onError: { (error) in
                    self.dataSource.value = []
                    print(error)
            }).addDisposableTo(disposeBag)


        //绑定数据源
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
        dataSource.asObservable().bindTo(self.tableView.rx_itemsWithCellIdentifier(identifier, cellType: UITableViewCell.self)){
            (_,item,cell) in
            cell.textLabel?.text = item.suggest
        }.addDisposableTo(disposeBag)

        //绑定点击
        tableView.rx_modelSelected(Suggestion).subscribeNext { (item) in
            print(item.suggest)
        }.addDisposableTo(disposeBag)

    }
}



// MARK: - APIs
extension PoiSearchViewController {
    func querySuggestion(address: String) -> Observable<[Suggestion]> {
        return Observable.create {
            (observer: AnyObserver<[Suggestion]>) -> Disposable in

            let url = "http://api.map.baidu.com/place/v2/suggestion?output=json&ak=wXCHMPUzYVHxgxUHGI0lZM3QvDrgkZd6"
            let params = ["query": address, "region": "深圳市"]

            let request = Alamofire.request(.GET, url, parameters: params, encoding: .URLEncodedInURL).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Failure(let error):
                    observer.onError(error)
                case .Success(let json):
                    observer.onNext(self.parseSuggestionJson(json))
                    observer.onCompleted()
                }
            })

            return AnonymousDisposable {
                request.cancel()
            }
        }
    }

    func parseSuggestionJson (respose: AnyObject) -> [Suggestion] {
        let json = JSON(respose)
        let items = json["result"]
        var result: [Suggestion] = []

        for (_, item): (String, JSON) in items {
            let city = item["city"].stringValue
            let district = item["district"].stringValue
            let suggest = item["name"].stringValue
            result.append(Suggestion(city: city, district: district, suggest: suggest))
        }

        return result
    }

}
