# Database Scripts

## run-sql.sh

Execute SQL commands directly against the footballhome database.

### Usage

```bash
./run-sql.sh "SQL_QUERY" [-f]
```

### Parameters

- `SQL_QUERY`: The SQL statement to execute (required, must be quoted)
- `-f`: Optional flag for formatted output (expanded display mode)

### Examples

**Simple SELECT query:**
```bash
./run-sql.sh "SELECT * FROM users;"
```

**COUNT query:**
```bash
./run-sql.sh "SELECT COUNT(*) FROM teams;"
```

**With formatted output:**
```bash
./run-sql.sh "SELECT name, email FROM users;" -f
```

**INSERT statement:**
```bash
./run-sql.sh "INSERT INTO clubs (name, display_name, slug) VALUES ('Test Club', 'Test Club', 'test-club');"
```

**JOIN query:**
```bash
./run-sql.sh "SELECT p.name, pc.display_name FROM permissions p JOIN permission_categories pc ON p.permission_category_id = pc.id LIMIT 5;"
```

**UPDATE statement:**
```bash
./run-sql.sh "UPDATE users SET phone = '555-1234' WHERE email = 'jbreslin@footballhome.org';"
```

### Prerequisites

- Docker and docker-compose must be installed
- Database container must be running (`docker compose up -d db`)

### Notes

- The script automatically checks if the database container is running
- It uses the `footballhome_user` credentials configured in docker-compose.yml
- Color-coded output: green for success, red for errors, yellow for info
- All SQL statements should end with a semicolon
- For multi-line queries, use standard bash quoting

### Multi-line Query Example

```bash
./run-sql.sh "
SELECT 
    t.name as team_name,
    sd.name as division_name,
    c.name as club_name
FROM teams t
JOIN sport_divisions sd ON t.division_id = sd.id
JOIN clubs c ON sd.club_id = c.id
LIMIT 10;
"
```
