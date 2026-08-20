# Bot & Web Scanner Protection with Fail2ban

Internet-facing Coneshare instances are regularly targeted by automated bots and vulnerability scanners probing for sensitive files (e.g., `.env`, `wp-config.php`, `.git`, `.htaccess`, backup archives, and database dumps).

While Coneshare safely returns `404 Not Found` for nonexistent routes, automated scans can:

- Consume network bandwidth and reverse proxy worker connections.
- Clutter access logs with thousands of probe attempts.
- Trigger false alerts in error monitoring systems or flood configured `ADMINS` notification channels.

Using **Fail2ban** alongside your Nginx reverse proxy allows you to automatically detect scanner patterns and block malicious IP addresses at the firewall (`iptables` / `nftables`) level before they reach your services.

---

## How It Works

```
Client (Scanner / Bot)
       │
       ▼
[ Nginx Reverse Proxy ] ──( logs 400 / 403 / 404 & User-Agents )──► /var/log/nginx/access.log
       │                                                                      │
       │                                                                      ▼
       │                                                               [ Fail2ban Daemon ]
       │                                                             ( evaluates 3 filters )
       │                                                                      │
       ▼                                                                      ▼
[ Drops connection via Firewall ] ◄───( adds ban rule to iptables )───────────┘
```

1. Nginx logs all incoming requests, status codes, and user-agents to `/var/log/nginx/access.log`.
2. The Fail2ban daemon monitors the access log in real time against three targeted filters:
   - **Vulnerability Scanner Filter (`nginx-scanner`)**: Catches probes for `.env`, `wp-config.php`, `.git`, `.bak`, `.sql`, etc.
   - **Repetitive 404 Filter (`nginx-404`)**: Limits aggressive brute-force path scanning.
   - **Automated Bot Filter (`nginx-badbots`)**: Catches automated HTTP scraping tools (`curl`, `wget`, `python`, `scrapy`, etc.) targeting web endpoints.
3. If an IP exceeds the configured retry limit, Fail2ban immediately bans the IP via `iptables` / `nftables`.

---

## Prerequisites

- Coneshare deployed with an Nginx reverse proxy on the host (see [Nginx Reverse Proxy Setup](reverse-proxy.md)).
- Root or `sudo` access on the host server.

---

## Step 1: Install Fail2ban

Install Fail2ban on your host machine:

=== "Ubuntu / Debian"

    ```bash
    sudo apt update
    sudo apt install fail2ban -y
    ```

=== "CentOS / RHEL / AlmaLinux"

    ```bash
    sudo dnf install epel-release -y
    sudo dnf install fail2ban fail2ban-systemd -y
    ```

Enable and start the Fail2ban service:

```bash
sudo systemctl enable --now fail2ban
```

---

## Step 2: Create the Filter Definitions

Create the three filter definitions in `/etc/fail2ban/filter.d/`:

### 1. Vulnerability Scanner Filter (`nginx-scanner.conf`)

Catches requests targeting sensitive configuration files, version control metadata, and database backups.

Create `/etc/fail2ban/filter.d/nginx-scanner.conf`:

```ini
[Definition]
failregex = <HOST> -.*"(GET|POST).*?(\/\.env|wp-config\.php|\.git|\.htaccess|\.bak|\.sql).*" (200|403|404)
ignoreregex =
```

### 2. Excessive 404 Scanner Filter (`nginx-404.conf`)

Catches aggressive directory fuzzing and crawler scans producing frequent 404 responses.

Create `/etc/fail2ban/filter.d/nginx-404.conf`:

```ini
[Definition]
failregex = <HOST> -.*"(GET|POST).*" 404
ignoreregex =
```

### 3. Bad Bots & Scraping Tools Filter (`nginx-badbots.conf`)

Detects common scripting user-agents used by automated scanning and scraping tools.

Create `/etc/fail2ban/filter.d/nginx-badbots.conf`:

```ini
[Definition]
failregex = <HOST> -.*"(GET|POST).*" .* "(curl|wget|python|aiohttp|scrapy|httpclient)"
ignoreregex =
```

---

## Step 3: Configure Jail Settings

Always define local configuration in `/etc/fail2ban/jail.local` rather than editing `jail.conf` directly.

Create or edit `/etc/fail2ban/jail.local`:

```ini
[DEFAULT]
# Default ban time: 1 day (86400 seconds)
bantime  = 86400

# Evaluation window: 10 minutes (600 seconds)
findtime = 600

# Default max retry count
maxretry = 3

# Whitelist trusted IP addresses (your office/home IP, LAN subnets, and localhost)
ignoreip = 127.0.0.1/8 ::1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

# Block traffic at firewall level using iptables multiport
banaction = iptables-multiport

# -------------------------------------------------------------
# 1. Vulnerability & Sensitive Path Scanners
# -------------------------------------------------------------
[nginx-scanner]
enabled  = true
port     = http,https
filter   = nginx-scanner
logpath  = /var/log/nginx/access.log
maxretry = 2
bantime  = 86400

# -------------------------------------------------------------
# 2. Repeated 404 Not Found Scans (Aggressive Directory Fuzzing)
# -------------------------------------------------------------
[nginx-404]
enabled  = true
port     = http,https
filter   = nginx-404
logpath  = /var/log/nginx/access.log
maxretry = 20
findtime = 60
bantime  = 43200

# -------------------------------------------------------------
# 3. Bad Bots / Automated Tool Probes
# -------------------------------------------------------------
[nginx-badbots]
enabled  = true
port     = http,https
filter   = nginx-badbots
logpath  = /var/log/nginx/access.log
maxretry = 2
bantime  = 86400
```

!!! tip "Tuning `nginx-404` Thresholds"
    For the `nginx-404` jail, set a higher `maxretry` (e.g., 20 retries within 60 seconds) so that regular users who encounter occasional missing assets or broken links are not accidentally banned.

---

## Step 4: Verify and Apply

### 1. Test Filter Rules Against Logs

Test each filter against your existing Nginx access logs using `fail2ban-regex`:

```bash
sudo fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/nginx-scanner.conf
sudo fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/nginx-404.conf
sudo fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/nginx-badbots.conf
```

### 2. Restart Fail2ban Service

Apply the new configuration:

```bash
sudo systemctl restart fail2ban
```

Verify that all three jails are running:

```bash
sudo fail2ban-client status
```

Expected output:

```text
Status
|- Number of jail:      3
`- Jail list:   nginx-404, nginx-badbots, nginx-scanner
```

---

## Step 5: Managing and Monitoring Bans

### Check Jail Activity

View status and currently banned IPs for a specific jail:

```bash
sudo fail2ban-client status nginx-scanner
sudo fail2ban-client status nginx-404
sudo fail2ban-client status nginx-badbots
```

### Unban an IP Address

If an IP is blocked accidentally, unban it with:

```bash
sudo fail2ban-client set nginx-scanner unbanip <IP_ADDRESS>
sudo fail2ban-client set nginx-404 unbanip <IP_ADDRESS>
sudo fail2ban-client set nginx-badbots unbanip <IP_ADDRESS>
```

### Manually Ban a Malicious IP

```bash
sudo fail2ban-client set nginx-scanner banip <IP_ADDRESS>
```

### Inspect Active Firewall Drop Rules

```bash
sudo iptables -L -n -v | grep f2b
```
