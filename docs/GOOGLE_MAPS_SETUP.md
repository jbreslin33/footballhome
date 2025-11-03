# Google Maps Geocoding API Setup

## Billing Alerts Setup

### 1. Set Budget Alerts
1. Go to **Billing** → **Budgets & alerts**
2. Create budget:
   - **Name**: "Geocoding API Budget"
   - **Amount**: $50/month
   - **Alert thresholds**: 50%, 90%, 100%
   - **Email notifications**: your-email@example.com

### 2. Set API Quotas
1. Go to **APIs & Services** → **Quotas**
2. Find "Geocoding API"
3. Set limits:
   - **Requests per day**: 1,000 (safety limit)
   - **Requests per minute**: 50

## Environment Variables Setup

Create `.env` file in your project root:

```bash
# Google Maps API Configuration
GOOGLE_MAPS_API_KEY=your_api_key_here
GEOCODING_RATE_LIMIT=50  # requests per minute
GEOCODING_DAILY_LIMIT=1000  # requests per day
GEOCODING_CACHE_TTL=86400  # 24 hours in seconds
```

## API Key Security
- Never commit API keys to git
- Use environment variables
- Restrict API key to specific IPs/domains
- Monitor usage regularly