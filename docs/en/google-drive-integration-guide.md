# Integrating Google Drive

This guide explains how to configure Google Drive as a file import source in Coneshare. By following these steps, you will enable users in your organization to connect their Google accounts and import files directly from Google Drive.

The process involves creating an OAuth 2.0 application in the Google Cloud Console and copying the credentials into your Coneshare admin settings.

---

### Step 1: Create and Configure a Google Cloud Project

First, you need to set up a project in the Google Cloud Platform to get the necessary API credentials.

1.  **Go to Google Cloud Console**: Open your web browser and navigate to the [Google Cloud Console](https://console.cloud.google.com/). Sign in with your Google account.

2.  **Create a New Project**:
    *   In the top menu bar, click the project selection dropdown.
    *   Click **New Project**.
    *   Give your project a name, such as "Coneshare Integration," and click **Create**.

3.  **Enable the Google Drive API**:
    *   Using the navigation menu (☰), go to **APIs & Services > Library**.
    *   In the search bar, type "Google Drive API" and press Enter.
    *   Click on "Google Drive API" in the search results and then click the **Enable** button.

4.  **Configure the OAuth Consent Screen**:
    *   From the navigation menu, go to **APIs & Services > OAuth consent screen**.
    *   Select **External** for the User Type and click **Create**.
    *   Fill in the required fields:
        *   **App name**: Enter a name that your users will recognize, like `Coneshare`.
        *   **User support email**: Select your email address.
        *   **Developer contact information**: Enter your email address.
    *   Click **Save and Continue**.
    *   On the "Scopes" screen, you don't need to add any scopes. Click **Save and Continue**.
    *   On the "Test users" screen, click **+ Add Users** and add your own Google account email address. This is required while your app is in "Testing" mode. Click **Save and Continue**.

### Step 2: Get OAuth 2.0 Credentials

Now you will create the Client ID and Client Secret that Coneshare needs to connect to Google.

1.  **Navigate to Credentials**: In the navigation menu, go to **APIs & Services > Credentials**.

2.  **Create OAuth Client ID**:
    *   Click **+ Create Credentials** at the top of the page and select **OAuth client ID**.
    *   For **Application type**, select **Web application**.
    *   Under the **Authorized redirect URIs** section, click **+ Add URI**.
    *   Enter the following URL, replacing `<your-coneshare-domain>` with your actual Coneshare site domain:
        ```
        https://<your-coneshare-domain>/auth/google_drive/callback
        ```
    *   Click the **Create** button.

3.  **Copy Your Credentials**: A pop-up window will appear showing your **Client ID** and **Client Secret**. Copy both of these values to a secure location. You will need them in the next step.

!!! danger "Important"
    Treat the Client Secret like a password. Do not share it publicly.

### Step 3: Add Credentials to Coneshare

Finally, enter the credentials you just created into the Coneshare admin panel.

1.  **Log in to Coneshare**: Sign in to your Coneshare instance with an administrator account.

2.  **Go to Admin Settings**: Navigate to the **Settings** page in the admin area.

3.  **Enter Credentials**:
    *   Find the **Cloud Services** section.
    *   Locate the following fields:
        *   `GOOGLE_DRIVE_CLIENT_ID`
        *   `GOOGLE_DRIVE_CLIENT_SECRET`
    *   Paste the **Client ID** and **Client Secret** you copied from the Google Cloud Console into the corresponding fields.

4.  **Save Settings**: Click the **Save** or **Update** button to apply the changes.

The integration is now complete. Your users will see a "Google Drive" option in the "Upload" menu, allowing them to connect their accounts and import files.
