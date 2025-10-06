#!/bin/bash

# ============================================================
# Gmail App Password Setup (Required for msmtp)
# 1. Go to: https://myaccount.google.com/security
# 2. Enable 2-Step Verification if not already enabled.
# 3. Under "App passwords", click "Generate app password".
# 4. Choose "Mail" as the app and "Other" or "Linux" as the device.
# 5. Copy the 16-character password shown (no spaces).
# 6. Paste it into MAIL_APP_PASSWORD below.
# ============================================================


# =================== USER CONFIGURATIONS ===================

USER_MAIL=""            # Your Gmail Adress
MAIL_APP_PASSWORD=""    #Gmail App Password (required for SMTP)

RECIPIENT=""
# ============================================================

# =================== GLOBAL CONFIGURATIONS ===================

LOG_DIR="$1"                                    # Directory to archive
TIMESTAMP=$(date +"%d-%m-%Y %H:%M:%S")          #Full timetamp for logs/email
LOG_TIMESTAMP=$(date +"%d-%m-%Y")                # Date only, for archive filename
ARCHIVE_FILE="logs_archive_$LOG_TIMESTAMP.tar.gz"     
ARCHIVE_DIR="$LOG_DIR"/archives                 # Destination folder for archive
LOG_FILE="/var/log/log_archive_history.log"     # History log file
MSMTP_CONF="$HOME/.msmtprc"                     # msmtp configuration path

# =============================================================


# Function: Check if msmtp is installed, if not, install and configure it
check_dependencies() {
  if ! command -v msmtp &> /dev/null; then
    echo "msmtp not found. Installing..."
    if grep -qi "ubuntu" /etc/os-release; then
      sudo apt update
      sudo apt install msmtp msmtp-mta -y

      elif grep -qi "centos" /etc/os-release; then
        sudo apt update
        sudo apt install msmtp msmtp-mta -y
      else
        echo "Unknown Linux Distribution"
    fi

    # Create msmtp configuration file
    cat > "$MSMTP_CONF" << EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        $HOME/msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           $USER_MAIL
user           $USER_MAIL
password       $MAIL_APP_PASSWORD

account default : gmail
EOF

chmod 600 "$MSMTP_CONF"         # Secure config file
  fi
}

# Function to send email notification about the archive
send_mail() {
  local MAIL=$(cat <<EOF
Logs Succesfully Archived on $TIMESTAMP
Archive Location: $ARCHIVE_DIR
EOF
)
  local MAIL_SUBJECT="Log Archive Report - $TIMESTAMP"

  # Send email via msmtp
  echo -e "Subject: $MAIL_SUBJECT\n\n$MAIL" | msmtp "$RECIPIENT"
}

if [[ -z "$LOG_DIR" ]]; then
  echo "Usage: $0 <archive directory>"
  exit 1
fi

if [[ -d $LOG_DIR ]]; then
  mkdir -p "$ARCHIVE_DIR"
  tar -cvzf "$ARCHIVE_FILE" -C "$LOG_DIR" .
  mv "$ARCHIVE_FILE" "$ARCHIVE_DIR"
  echo "$TIMESTAMP - Archive Logs From $LOG_DIR to $ARCHIVE_DIR/$ARCHIVE_FILE" >> $LOG_FILE


  # Send email only if all credentials are set
  if [[ -n $USER_MAIL && -n $MAIL_APP_PASSWORD && -n $RECIPIENT ]]; then
    check_dependencies
    send_mail
  else
    echo "No Valid Email or Password Detected. Skipping Email."
  fi

else
  echo "File Directory does not exist"
  exit 1
fi