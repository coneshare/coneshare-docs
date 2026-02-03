# **Configuration**

Coneshare's behavior is controlled by two primary configuration files:

- **`.env`**: Controls the deployment environment, such as service ports and system resource checks.
- **`app.env`**: Configures the Coneshare application itself, including the site domain and email settings.

Both files are located in your installation directory, `/opt/coneshare/coneshare-compose/`.

## **Environment Configuration (`.env`)**

You can customize the installation script and Docker Compose environment by creating a `.env` file.

!!! tip "Docker Compose Version"
    Customizing with a `.env` file requires Docker Compose version `2.17.0` or higher.
    ```sh
    docker compose version
    ```

To override the default settings, create `/opt/coneshare/.env` with your desired values. This will override any defaults set within the `coneshare-compose` directory. Commonly modified parameters include:

```env
# The host port that the service is bound to.
CONESHARE_BIND=8999

# The minimum memory (in MB) required by the installation script.
MIN_RAM_HARD=4000

# The minimum CPU cores required by the installation script.
MIN_CPU_HARD=2
```

### **Change Service Port**

By default, Coneshare binds to port `8999`. To change this, set `CONESHARE_BIND` to your desired port in `/opt/coneshare/.env`.
```env
# Example: Change the port to 8080
CONESHARE_BIND=8080
```
After saving the file, restart the service to apply the change.

### **Adjust System Resource Checks**

The installation script checks for at least 2 CPU cores and 4 GB of RAM. If your system has fewer resources, you can lower these checks in `/opt/coneshare/.env`.
```env
# Example: Lower requirements to 1 CPU and 2 GB RAM
MIN_CPU_HARD=1
MIN_RAM_HARD=2000
```
After saving, re-run the `install.sh` script to apply the new configuration.

!!! warning
    Lowering resource requirements may lead to system instability. For production use, we recommend adhering to the default requirements for optimal performance.

## **Application Configuration (`app.env`)**

The `app.env` file, located at `/opt/coneshare/coneshare-compose/app.env`, is generated during installation and contains settings specific to the Coneshare application.

### **Site Domain**

You must configure `SITE_DOMAIN` to match your server's public-facing IP address or domain name. This is critical for generating correct share links.

Edit `/opt/coneshare/coneshare-compose/app.env` and set the variable:
```env
# Example: Using an IP address
SITE_DOMAIN=http://10.8.1.1:8999

# Example: Using a domain name
SITE_DOMAIN=https://coneshare.example.com
```
Restart the service after making changes.

### **Email Sending**

Features like password resets require a configured email service. To enable this, add your SMTP server credentials to `/opt/coneshare/coneshare-compose/app.env`.

```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.mail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=no-reply@example.com
EMAIL_HOST_PASSWORD=your-email-password
DEFAULT_FROM_EMAIL=no-reply@example.com
```

Below is an example for a Gmail account:
=== "Gmail"
    ```env
    EMAIL_HOST=smtp.gmail.com
    EMAIL_PORT=587
    EMAIL_USE_TLS=True
    EMAIL_HOST_USER=your-account@gmail.com
    EMAIL_HOST_PASSWORD=your-app-password
    DEFAULT_FROM_EMAIL=your-account@gmail.com
    ```

!!! info
    The `EMAIL_USE_TLS` setting depends on your provider's requirements. Port 587 typically requires TLS. For more details, see the [Django Email Settings](https://docs.djangoproject.com/en/stable/ref/settings/#email-use-tls) documentation.

After adding the email configuration, restart the service.

