# Log Archiver with Gmail Notification

This Bash script automates the process of archiving log files from a specified directory, storing them in an `archives` folder, and optionally sending a notification email through Gmail using `msmtp`.

---

## Features

- Automatically compresses logs into a `.tar.gz` archive
- Maintains a history of archived operations
- Configures and uses `msmtp` for Gmail-based email alerts
- Works on Ubuntu and CentOS distributions

---

## Gmail App Password Setup (Required for msmtp)

1. Go to [https://myaccount.google.com/security](https://myaccount.google.com/security)
2. Enable **2-Step Verification** if not already enabled.
3. Under **App passwords**, click **Generate app password**.
4. Choose **Mail** as the app and **Other** or **Linux** as the device.
5. Copy the 16-character password shown (no spaces).
6. Paste it into the `MAIL_APP_PASSWORD` variable in the script.

---

## How It Works

1. The script checks if `msmtp` is installed — if not, it installs and configures it automatically.
2. It compresses logs from the specified directory into a timestamped `.tar.gz` file.
3. The archive is moved into a `/archives` subfolder.
4. A log entry is appended to `/var/log/log_archive_history.log`.
5. An email notification is sent via Gmail (if configured).

---

## Variables Configuration

Inside the script:

```bash
USER_MAIL=""            # Your Gmail Address
MAIL_APP_PASSWORD=""    # Gmail App Password (from Google App Passwords)
RECIPIENT=""            # Email address to send notifications to
```

---

## Usage

```bash
chmod +x log_archiver.sh
./log_archiver.sh /path/to/logs
```

Example:

```bash
./log_archiver.sh /var/log/myapp
```

---

## Email Notification Example

When the script runs successfully, you’ll receive an email like this:

```
Subject: Log Archive Report - 06-10-2025 14:25:30

Logs Successfully Archived on 06-10-2025 14:25:30
Archive Location: /var/log/myapp/archives
```

---

## File Structure

```
log_archiver.sh
README.md
```

---

## Log History

All activities are logged in:

```
/var/log/log_archive_history.log
```

Each entry includes the timestamp, source directory, and archive path.

---

## Notes

- Ensure you’ve configured Gmail with a valid **App Password**.
- The script automatically sets permissions to secure your `.msmtprc` file.
- Requires `sudo` privileges for installation if `msmtp` is missing.
