import SQLite

struct Story {
    let id: Int
    let content: String?
    let categories: Int?
}
enum DataTable: String {
    case meet = "landau_gap"
    case confess = "loi_to_tinh"
    case happyDay = "cauchuyen_hanhphuc"
    case proposal = "loi_cau_hon"
    case weddingDay = "loi_phat_bieu_dam_cuoi"
}

class DatabaseManager {
    static let shared = DatabaseManager()
    var db: Connection?

    private init() {
        connectDatabase()
    }

    func connectDatabase() {
        do {
            if let path = Bundle.main.path(forResource: "database_text (1)", ofType: "db") {
                db = try Connection(path, readonly: true)
            } else {
                print("Database file not found")
            }
        } catch {
            print("Unable to open database: \(error)")
        }
    }

    func fetchDataStory(table: DataTable.RawValue) -> [Story] {
        var stories = [Story]()
        do {
            if let db = db {
                let table = Table(table)
                let id = Expression<Int>("id")
                let noidung = Expression<String?>("noidung")
                let categories = Expression<Int?>("categories")

                for row in try db.prepare(table.select(id, noidung, categories)) {
                    let story = Story(
                        id: row[id],
                        content: row[noidung],
                        categories: row[categories]
                    )
                    stories.append(story)
                }
            }
        } catch {
            print("Fetch data failed: \(error)")
        }
        return stories
    }
}

