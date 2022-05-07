
import UIKit
import RxCocoa
import RxSwift
import SnapKit

class ChooseStore: UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChooseStore")
        configureConstr()
        tableView.register(StoresTabCell.self, forCellReuseIdentifier: storesFeedCellId)
    }
    var chooseStoreData = [StoresFeedModel]()
    private let storesFeedCellId = "StoresFeedCellID"
    var newData = StoresData()
    var disposeBag = DisposeBag()
    lazy var tableView : UITableView = {
    let tbv = UITableView()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.rowHeight = UITableView.automaticDimension
        tbv.backgroundColor = .gray
        tbv.estimatedRowHeight = 150
    return tbv
    }()
    func configureConstr(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { tableView in
            tableView.right.equalTo(view.snp.right).offset(-10)
            tableView.left.equalTo(view.snp.left).offset(10)
            tableView.bottom.equalTo(view.snp.bottom).offset(-200)
            tableView.top.equalTo(view.snp.top).offset(50)
        }
    }
    func bindTableView(){
        newData.businesses.asObservable()
        .bind(to: tableView
                .rx
                .items(cellIdentifier: storesFeedCellId, cellType: StoresTabCell.self)
        ) {
            row, businessData, cell in
            cell.configureWithData(dataModel: businessData)
        }.disposed(by: disposeBag)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chooseStoreData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: storesFeedCellId, for: indexPath) as! StoresTabCell
        return cell
    }
}
