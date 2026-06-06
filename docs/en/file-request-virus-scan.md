# File Request Virus Scan

Coneshare can scan files uploaded through public [File Request](https://www.coneshare.com/features/file-requests) links before they become workspace documents. This helps reduce risk from external uploaders while keeping the rollout optional for each deployment.

!!! info "Scope"
    Virus scanning currently applies to public File Request uploads only.
    Internal authenticated document uploads are not scanned by this feature.

## How It Works

When a visitor uploads a file through a File Request link, Coneshare checks the uploaded object during upload finalization.

The flow is:

1. The uploader submits a file through a public File Request page.
2. Coneshare receives the uploaded object and starts finalization.
3. If virus scanning is enabled, Coneshare streams the file to ClamAV.
4. If the file is clean, Coneshare creates the document normally.
5. If malware is detected, Coneshare blocks the file and records a security event.
6. If the scanner is unavailable and fail-closed mode is enabled, Coneshare rejects the upload and asks the uploader to try again later.

The uploader sees a friendly error message instead of scanner details.

## Requirements

To enable virus scanning, your deployment needs:

- Coneshare version `1.4.0` or later
- Virus scanning enabled in `app.env`
- The malware scanning profile started with the official `coneshare-compose` helper

!!! tip "Memory Requirement"
    ClamAV typically consumes an additional `1-2 GB` of memory for its engine and signature database.
    Enable virus scanning only on deployments with at least `8 GB` of available system memory.

## Configuration

Add or update the following values in `/opt/coneshare/app.env`.

```env
MALWARE_SCAN_ENABLED=true
CLAMAV_HOST=clamav
CLAMAV_PORT=3310
MALWARE_SCAN_TIMEOUT_MS=10000
MALWARE_SCAN_FAIL_MODE=closed
```

### Settings Reference

| Setting | Default | Description |
| --- | --- | --- |
| `MALWARE_SCAN_ENABLED` | `false` | Enables malware scanning for public File Request uploads. |
| `CLAMAV_HOST` | `clamav` | Hostname of the ClamAV service. |
| `CLAMAV_PORT` | `3310` | TCP port used by ClamAV. |
| `MALWARE_SCAN_TIMEOUT_MS` | `10000` | Maximum time Coneshare waits for the scan result. |
| `MALWARE_SCAN_FAIL_MODE` | `closed` | Controls what happens if scanning cannot complete. Use `closed` to reject uploads when the scanner is unavailable, or `open` to allow uploads when scanning fails. |

!!! warning "Fail Mode"
    `closed` is the recommended production setting because it prevents unscanned public uploads from becoming documents.
    Use `open` only when upload availability is more important than scan enforcement.

## Start ClamAV

The official `coneshare-compose` deployment includes a ClamAV service. Start Coneshare with the malware profile to include the scanner service.

```sh
cd /opt/coneshare/coneshare-compose
./start.sh --profile malware
```

To stop Coneshare when the malware profile is enabled, pass the same profile to the stop script.

```sh
./stop.sh --profile malware
```

For deployments without virus scanning, continue using the normal start and stop commands.

```sh
./start.sh
./stop.sh
```

## Uploader Experience

When a file is blocked by the scan, the public upload page shows:

> This file was blocked by our security scan. Please remove it and upload a different file.

When the scanner is unavailable and fail-closed mode blocks the upload, the public upload page shows:

> Uploads are temporarily unavailable because the security scanner is offline. Please try again later.

These messages are intentionally general and do not expose scanner internals to the uploader.

## Security Events

Coneshare records security events for scan incidents so administrators have an audit trail.

Recorded event types include:

- `malware_detected`: a file was blocked because ClamAV reported malware.
- `scan_failed`: a file could not be scanned and the upload was rejected.

Security event records include the File Request context, uploader details, file metadata, scanner engine, and scanner message when available.

## Automation Alerts

Virus scan events can be delivered through [Coneshare Automations](https://www.coneshare.com/features/workflow-automation-integration).

Supported automation events include:

- `file_request_malware_detected`
- `file_request_scan_failed`

These events are available for global automation rules. Alert payloads include organization context, File Request metadata, uploader metadata, file metadata, and the security event ID.

For chat-style destinations such as Slack, WeChat, FeiShu, and Discord, Coneshare formats alert messages with the uploader, filename, and File Request slug.

## Validation Checklist

- `MALWARE_SCAN_ENABLED=true` is set in `/opt/coneshare/app.env`
- ClamAV service is up and running by `./dc ps`
- Public File Request uploads still complete for clean files
- Malware test uploads are blocked
- Scanner outage behavior matches `MALWARE_SCAN_FAIL_MODE`
- Security events appear in the admin area
- Automation rules receive `file_request_malware_detected` and `file_request_scan_failed` events when configured

## Troubleshooting

### Clean files are blocked with a scanner unavailable message

Check that the ClamAV container is running and reachable on `CLAMAV_HOST` and `CLAMAV_PORT`.

```sh
cd /opt/coneshare/coneshare-compose
./dc ps
```

If ClamAV is still starting, wait for its database initialization to finish and retry the upload.

### Uploads continue when the scanner is unavailable

Confirm that fail-closed mode is enabled.

```env
MALWARE_SCAN_FAIL_MODE=closed
```

Restart Coneshare after changing the setting.

### No automation alerts are delivered

Confirm that a global automation rule exists for the relevant event:

- `file_request_malware_detected`
- `file_request_scan_failed`

Also check the automation delivery logs for retry or destination errors.
