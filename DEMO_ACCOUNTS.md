# Demo Accounts

## Available Test Accounts

The following demo accounts are available for testing the Football Home application:

### **Admin Account**
- **Email**: `jbreslin@footballhome.org`
- **Name**: James Breslin
- **Role**: Administrator (admin, coach, player roles)
- **Password**: `1893Soccer!`

### **Test Accounts**  
- **Email**: `test@test.com`
- **Name**: Test User
- **Password**: `password` (likely)

- **Email**: `testuser@example.com`  
- **Name**: Test User
- **Password**: `password` (likely)

## **Access URLs**

- **Vanilla JS (Default)**: http://localhost:3000 or http://footballhome.org
- **React Version**: http://localhost:3002  
- **API**: http://localhost:3001

## **Testing Login Flow**

1. Go to http://localhost:3000
2. Try credentials: `test@test.com` / `password`
3. Watch browser console for FSM state transitions:
   ```
   AuthService initialized with API URL: http://footballhome.org:3001
   FSM initialized with state: idle
   LoginForm: idle -> validating
   FSM: validating --[VALIDATION_SUCCESS]--> submitting
   FSM: submitting --[LOGIN_SUCCESS]--> success
   ```

## **Troubleshooting**

If you get network errors:
- Check that backend is running: `docker compose ps`
- Verify API URL in console logs
- Test API directly: `curl http://localhost:3001/health`

For password issues:
- Try `password` for test accounts
- Check database: `docker exec footballhome_db psql -U footballhome_user -d footballhome -c "SELECT email, name FROM users;"`