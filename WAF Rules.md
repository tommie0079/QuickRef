# Cloudflare Tunnel: Human Verification Setup

This guide explains how to protect your Cloudflare Tunnel with a **"Verify you are human"** (Managed Challenge) screen. 

> **Note:** This configuration is handled via **WAF (Web Application Firewall)** rules at the domain level, not within the Tunnel settings themselves.

## 📋 Prerequisites

* A Cloudflare account with an active domain.
* A running Cloudflare Tunnel connected to a public hostname (e.g., `app.example.com`).
    * *Verify this in: `Zero Trust > Access > Tunnels`*

---

## ⚙️ Configuration Steps

### 1. Navigate to WAF Rules
1.  Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2.  Select the **Domain** (Website) where your tunnel is hosted.
3.  On the left sidebar, navigate to **Security** > **Security rules**.
4.  Click on the **+ Create rule** tab.
5.  Click the blue **+ Create rule** button.

### 2. Configure the Rule
Set up the rule to intercept traffic before it hits your tunnel. Use the following configuration:

| Setting | Value |
| :--- | :--- |
| **Rule Name** | `Tunnel Human Verification` (or custom name) |
| **Field** | `Hostname` |
| **Operator** | `equals` |
| **Value** | `app.example.com` (Your Tunnel URL) |
| **Action** | `Managed Challenge` |

> **Tip:** **"Managed Challenge"** automatically selects the appropriate difficulty (often seamless). If you specifically require a visible checkbox, select **"Interactive Challenge"** instead.

### 3. Deploy
Click **Deploy** to save and activate the rule immediately.

---

## ✅ Verification

To ensure the rule is working:
1.  Open a new **Incognito/Private** browser window (to avoid cached validation).
2.  Visit your tunnel URL (e.g., `app.example.com`).
3.  You should see the Cloudflare interstitial page ("Verify you are human") before your application loads.

---

## ⚠️ Important Considerations

### API & Bot Traffic
This method effectively blocks simple bots, but it will also break **API access** or automated scripts accessing your tunnel (since they cannot interact with the challenge page).
* *Solution:* Add logic to your WAF rule to exclude specific User Agents or IP ranges if API access is required.

### Access vs. Challenge
* **Use WAF (This Guide):** If you want to make the site public but protect it from DDoS and generic bots.
* **Use Cloudflare Access:** If you need to restrict access to specific people (e.g., "Login with Google/Email"). Go to `Zero Trust > Access > Applications` for authentication setup.
