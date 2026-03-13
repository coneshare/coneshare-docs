# Setting up a Reverse Proxy for Coneshare

For production environments, using a reverse proxy is strongly recommended. It allows you to terminate SSL/TLS and forward client IP addresses to the application, providing a more secure and robust setup.

### Install Letsencrypt

Refer to this complete doc about how to install letsencrpt:
[https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04](https://www.digitalocean.com/community/tutorial
s/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04)

### Enabling HTTPS

Here is an example Nginx configuration for enabling HTTPS. This configuration assumes you are using Certbot for SSL certificates.

```nginx
upstream coneshare_web {
  # fail_timeout=0 means we always retry an upstream even if it failed
  # to return a good HTTP response

  # for a TCP configuration
  server localhost:8999 fail_timeout=0;
}

server {
    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;
    server_name coneshare.example.com; # managed by Certbot
    client_max_body_size 1G;
    location / {
        try_files $uri @proxy_to_app;

    }

    location @proxy_to_app {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $http_host;
      # we don't want nginx trying to do something clever with
      # redirects, we set the Host: header above already.
      proxy_redirect off;
      proxy_pass http://coneshare_web;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/coneshare.example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/coneshare.example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = coneshare.example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80 ;
    listen [::]:80 ;
    server_name coneshare.example.com;
    return 404; # managed by Certbot
}
```

Finally, update SITE_DOMAIN in app.env and restart the Coneshare service.
