# Remote MCP Server Configuration

!!! info "Added in v1.8.0"
    Remote Model Context Protocol (MCP) server support is available starting in Coneshare **v1.8.0**.

!!! tip "Optional Component & Zero Idle Overhead"
    The Remote MCP Server is **completely optional**. 
    
    While the lightweight service container runs by default in the Docker stack, it binds exclusively to the host loopback interface (`127.0.0.1:18999`) and remains entirely inaccessible from external networks unless a system administrator explicitly configures Nginx to route traffic to it. 
    
    When not exposed or actively serving AI agent requests, the service sits idle and consumes virtually zero CPU and negligible memory. If your team does not use AI coding assistants or desktop agents, you can simply skip the `/mcp/` Nginx configuration without impacting any standard Coneshare functionality.

Coneshare provides an official **Remote MCP Server** (`coneshare-mcp`) that enables AI coding assistants, IDE extensions, and desktop LLM clients (such as Claude Desktop, Claude Code CLI, Antigravity CLI `agy`, and Codex) to interact directly with your Coneshare instance over secure Server-Sent Events (SSE) network streams.

---

## Architectural Overview

The MCP server runs as a lightweight service in the Docker Compose stack, exposing an HTTP/SSE endpoint at path `/mcp/sse`.

```text
+-------------------------------------------------------------+
|                      AI Agent Clients                       |
|     (Claude Desktop, Claude Code CLI, Antigravity, Codex)   |
+-------------------------------------------------------------+
                              |
                              |  HTTPS / SSE  (Bearer cs_live_...)
                              v
+-------------------------------------------------------------+
|                     Nginx Reverse Proxy                     |
|         (Public Port 443 / SSL & proxy_buffering off)       |
+-------------------------------------------------------------+
                              |
                              |  HTTP / SSE  (Host Loopback :18999)
                              v
+-------------------------------------------------------------+
|                Coneshare Remote MCP Server                  |
|         (Container Port 8001 / FastMCP Protocol Hub)        |
+-------------------------------------------------------------+
                              |
                              |  REST API  (Docker Internal Network)
                              v
+-------------------------------------------------------------+
|                   Coneshare Web Server                      |
|        (Django Backend :8000 + Database & Object Storage)   |
+-------------------------------------------------------------+
```

- **Public Endpoint Path:** `https://your-domain.com/mcp/sse` (Port `443` via Nginx)
- **Host Loopback Port:** `18999` (bound to `127.0.0.1:18999` by default)
- **MCP Container Port:** `8001` (`coneshare-mcp` service)
- **Backend Internal Communication:** Communicates directly over the Docker internal network (`http://web:80/api/v1`)
- **Authentication:** Header-driven, stateless per-request authentication using user API keys (`cs_live_...`). No master API key is stored on the server.

---

## Complete Nginx Reverse Proxy Configuration

Below is the full, production-ready Nginx configuration enabling both standard Coneshare web traffic and the Remote MCP Server endpoint over HTTPS:

```nginx
# ------------------------------------------------------------------------------
# Coneshare Web App Upstream
# ------------------------------------------------------------------------------
upstream coneshare_web {
  server localhost:8999 fail_timeout=0;
}

# ------------------------------------------------------------------------------
# Remote MCP Server Upstream (maps to host loopback port 18999)
# ------------------------------------------------------------------------------
upstream coneshare_mcp {
  server localhost:18999 fail_timeout=0;
}

server {
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name coneshare.example.com; # managed by Certbot
    client_max_body_size 1G;

    # ------------------------------------------------------------------------------
    # Remote MCP Server Stream & Gateway (https://coneshare.example.com/mcp/sse)
    # ------------------------------------------------------------------------------
    location /mcp/ {
        proxy_pass http://coneshare_mcp;

        # Disable proxy buffering for long-lived Server-Sent Events (SSE) streams
        proxy_http_version 1.1;
        proxy_set_header Connection '';
        proxy_set_header Chunked_Transfer_Encoding off;
        proxy_buffering off;
        proxy_cache off;

        # Extended timeouts for persistent SSE connections (24 hours)
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;

        # Forward real client IP and headers (including Authorization Bearer tokens)
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Authorization $http_authorization;

        proxy_redirect off;
    }

    # ------------------------------------------------------------------------------
    # Coneshare Web Application & API
    # ------------------------------------------------------------------------------
    location / {
        try_files $uri @proxy_to_app;
    }

    location @proxy_to_app {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://coneshare_web;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/coneshare.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/coneshare.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

# ------------------------------------------------------------------------------
# HTTP to HTTPS Redirect
# ------------------------------------------------------------------------------
server {
    if ($host = coneshare.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;
    server_name coneshare.example.com;
    return 404; # managed by Certbot
}
```

---

## Mandatory Nginx Directives Explained

When proxying Server-Sent Events (SSE) for AI agents, three configuration requirements must be met:

1. **`proxy_buffering off;` and `proxy_cache off;`**  
   Nginx buffers response streams in memory by default. Disabling buffering ensures MCP tool responses and JSON-RPC message chunks are flushed immediately to connected AI clients without delay.

2. **`proxy_read_timeout 86400s;` and `proxy_send_timeout 86400s;`**  
   AI coding sessions remain connected for extended periods. Setting the timeout to 24 hours prevents Nginx from prematurely closing idle SSE streams between tool invocations.

3. **`proxy_set_header Authorization $http_authorization;`**  
   The Coneshare MCP server is stateless and extracts the user's Bearer API key (`Authorization: Bearer cs_live_...`) directly from incoming connection headers. If this header is omitted, tool calls will fail with `401 Unauthorized`.

---

## Application Configuration (`app.env`)

Ensure your `/opt/coneshare/app.env` file includes the MCP server communication settings:

```env
# ------------------------------------------------------------------------------
# Remote MCP Server (coneshare-mcp)
# ------------------------------------------------------------------------------
# Target REST API URL as seen from mcp_server container
CONESHARE_API_URL=http://web:80/api/v1

# Transport mode (streamable-http or sse)
MCP_TRANSPORT=streamable-http

# HTTP SSE endpoint path
MCP_PATH=/mcp/sse
```

### Restart the Service

After updating `/opt/coneshare/app.env`, restart the Coneshare services to apply the changes:

```bash
cd /opt/coneshare
./start.sh
```

---

## Verifying the Deployment

After restarting Coneshare and reloading Nginx (`sudo nginx -t && sudo nginx -s reload`), verify that the endpoint is reachable:

```bash
curl -i -N -H "Accept: text/event-stream" https://your-domain.com/mcp/sse
```

An expected, healthy response from the FastMCP server will look like this:

```http
HTTP/1.1 400 Bad Request
Server: nginx/...
Content-Type: application/json
mcp-session-id: 339d4a60c8514cfaaf4a7a5f7b907e45

{"jsonrpc":"2.0","id":"server-error","error":{"code":-32600,"message":"Bad Request: Missing session ID"}}
```

!!! success "Why `400 Bad Request` confirms the setup is OK"
    The Model Context Protocol (MCP) requires a proper session initialization handshake that standard command-line tools like `curl` do not send by default. 
    
    Receiving this response with the `mcp-session-id` header and the JSON-RPC message `"Bad Request: Missing session ID"` confirms that:
    
    1. Nginx successfully intercepted and routed the `/mcp/` path to the upstream `coneshare_mcp` service on port `18999`.
    2. The `coneshare-mcp` service is running, listening, and actively parsing MCP JSON-RPC protocol packets.

---

## Connecting AI Clients

Users can generate API keys directly under **Settings > API Keys** in the Coneshare web interface. Below are example client configurations:

=== "Claude Desktop"
    Add the server to `claude_desktop_config.json`:
    ```json
    {
      "mcpServers": {
        "coneshare": {
          "url": "https://your-domain.com/mcp/sse",
          "headers": {
            "Authorization": "Bearer cs_live_YOUR_API_KEY"
          }
        }
      }
    }
    ```

=== "Claude Code CLI"
    Run the command in your terminal:
    ```bash
    claude mcp add --transport sse coneshare https://your-domain.com/mcp/sse --header "Authorization: Bearer cs_live_YOUR_API_KEY"
    ```

=== "Antigravity CLI (agy)"
    Configure `mcpServers` in your configuration file:
    ```json
    {
      "mcpServers": {
        "coneshare": {
          "url": "https://your-domain.com/mcp/sse",
          "headers": {
            "Authorization": "Bearer cs_live_YOUR_API_KEY"
          }
        }
      }
    }
    ```

=== "Codex / VS Code"
    Configure your IDE MCP settings:
    ```json
    {
      "mcpServers": {
        "coneshare": {
          "url": "https://your-domain.com/mcp/sse",
          "headers": {
            "Authorization": "Bearer cs_live_YOUR_API_KEY"
          }
        }
      }
    }
    ```
