const String tableCategories = 'categories';
const String tableTransactions = 'transactions';
const String tableBudgets = 'budgets';
const String tableMonthlyBudgets = 'monthly_budgets';

const String createCategoriesTable = '''
  CREATE TABLE $tableCategories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    type TEXT NOT NULL,
    is_default INTEGER DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    color TEXT
  )
''';

const String createTransactionsTable = '''
  CREATE TABLE $tableTransactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    type TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    note TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (category_id) REFERENCES $tableCategories(id)
  )
''';

const String createBudgetsTable = '''
  CREATE TABLE $tableBudgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    month TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES $tableCategories(id)
  )
''';

const String createMonthlyBudgetsTable = '''
  CREATE TABLE $tableMonthlyBudgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    month TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
''';