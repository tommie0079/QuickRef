### Setup Instructions

1. Go to [Cloudflare Zero Trust](https://one.dash.cloudflare.com/) dashboard
2. Navigate to **Access → Applications → Add an Application**
3. Choose **Self-hosted** and enter your Netdata domain
4. Add a policy (e.g., "Allow emails ending in @yourdomain.com")
5. Point your Cloudflare Tunnel to `http://localhost:port`

Cloudflare handles all authentication before traffic reaches your server — no additional containers needed.

