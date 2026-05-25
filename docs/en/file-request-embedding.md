# Configuring File Request Embedding Behind a Reverse Proxy

!!! warning "Reverse Proxy Is Required"
    This setup is supported only when Coneshare is deployed behind a front reverse proxy (for example Nginx).
    Do not configure embedding by changing container-internal web server config.

For production, control iframe embedding at the HTTPS edge (your reverse proxy). This keeps secure defaults for all routes and allows embedding only where needed.

## Goal

Allow iframe embedding for file request upload pages:

- `/upload/<file_request_slug>?embed=1`

Keep all other Coneshare routes non-embeddable.

## Prerequisites

- Reverse proxy terminates HTTPS for your public domain (for example `coneshare.example.com`)
- Coneshare is reachable from the proxy upstream (for example `localhost:8999`)
- `SITE_DOMAIN` is set correctly in `/opt/coneshare/app.env` (for example `https://coneshare.example.com`)

## Recommended Policy

- Default all routes to not embeddable
- Allow embedding only on `/upload/*`
- Restrict `frame-ancestors` to trusted origins only
- Remove upstream conflicting frame headers on the embed-enabled route

## Nginx Example

Use the following pattern inside your HTTPS server block.

```nginx
upstream coneshare_web {
  server localhost:8999 fail_timeout=0;
}

server {
  server_name coneshare.example.com;
  client_max_body_size 1G;

  listen 443 ssl;
  listen [::]:443 ssl ipv6only=on;
  ssl_certificate /etc/letsencrypt/live/coneshare.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/coneshare.example.com/privkey.pem;
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

  # Default: deny framing on all routes
  location / {
    add_header X-Frame-Options "DENY" always;
    add_header Content-Security-Policy "frame-ancestors 'none'" always;

    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $host;
    proxy_redirect off;
    proxy_pass http://coneshare_web;
  }

  # Embed-enabled route only
  location ~ ^/upload/ {
    # Remove upstream frame headers if present
    proxy_hide_header X-Frame-Options;
    proxy_hide_header Content-Security-Policy;

    # Allow only trusted embed origins
    add_header Content-Security-Policy "frame-ancestors 'self' https://www.example.com https://portal.partner.com" always;

    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $host;
    proxy_redirect off;
    proxy_pass http://coneshare_web;
  }
}

server {
  listen 80;
  listen [::]:80;
  server_name coneshare.example.com;
  return 301 https://$host$request_uri;
}
```

!!! warning "Preserve CSP Carefully"
    The upload location above replaces upstream `Content-Security-Policy` with a route-level policy focused on framing.
    If you maintain a broader CSP policy, include required directives instead of sending only `frame-ancestors`.

## Embed Snippet

```html
<iframe
  src="https://coneshare.example.com/upload/<file_request_slug>?embed=1"
  title="Secure file upload"
  width="100%"
  height="760"
  style="border:0;max-width:720px"
  loading="lazy"
  referrerpolicy="strict-origin-when-cross-origin">
</iframe>
```

## Practical Guide

For a business and IT focused walkthrough, read:

- [How to Receive Large Files Securely from Clients (Self-Hosted Guide)](https://www.coneshare.com/blog/how-to-receive-large-files-securely-from-clients-self-hosted-guide)

This guide covers practical rollout topics, including:

- File Request link workflows
- Policy controls and link expiration
- Auditability and traceability
- Automated notifications
- A live embedding page you can use as a reference implementation

## Validation Checklist

- Allowed origin: `/upload/<slug>?embed=1` loads in an iframe
- Non-allowlisted origin: same URL is blocked by browser framing policy
- Non-upload routes (for example `/`, `/features`) cannot be embedded
- Upload size works as expected (`client_max_body_size`)
- Header checks:
  - `/` returns `X-Frame-Options: DENY` and `frame-ancestors 'none'`
  - `/upload/<slug>?embed=1` returns allowlisted `frame-ancestors`

## Final Step

After proxy changes:

1. Test config and reload Nginx:
   ```sh
   nginx -t && systemctl reload nginx
   ```
2. Confirm `SITE_DOMAIN` in `/opt/coneshare/app.env`
3. Restart Coneshare only if `SITE_DOMAIN` was changed
