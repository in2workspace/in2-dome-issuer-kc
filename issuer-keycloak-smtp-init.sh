#!/bin/bash

# Define the path to the realm file
REALM_FILE="/opt/keycloak/data/import/CredentialIssuer-realm.json"
TEMP_FILE="/tmp/CredentialIssuer-realm.json"

# Ensure the original realm file is readable
if [[ -r $REALM_FILE ]]; then
  # Copy the realm file to a temporary writable location
  cp $REALM_FILE $TEMP_FILE

  # Function to update or add JSON values within smtpServer using sed and awk
  update_json_in_smtpServer() {
    local key=$1
    local value=$2

    # Use sed to replace the value for the given key within the smtpServer object
    sed -i "/\"smtpServer\"/,/}/s/\"\($key\"\s*:\s*\)\"[^\"]*\"/\"\1\"$value\"/" "$TEMP_FILE"
  }

  # Update or add the JSON values within smtpServer
  update_json_in_smtpServer "host" "$SMTP_HOST"
  update_json_in_smtpServer "port" "$SMTP_PORT"
  update_json_in_smtpServer "user" "$SMTP_USER"
  update_json_in_smtpServer "password" "$SMTP_PASSWORD"
  update_json_in_smtpServer "from" "$SMTP_FROM"
  update_json_in_smtpServer "fromDisplayName" "$SMTP_FROM_DISPLAY_NAME"
  update_json_in_smtpServer "replyTo" "$SMTP_REPLY_TO"
  update_json_in_smtpServer "starttls" "$SMTP_STARTTLS"
  update_json_in_smtpServer "auth" "$SMTP_AUTH"
  update_json_in_smtpServer "ssl" "$SMTP_SSL"

  # Overwrite the original file with the modified content
  cat $TEMP_FILE > $REALM_FILE
else
  echo "Error: Cannot read $REALM_FILE. Please check the file permissions."
  exit 1
fi

# Start Keycloak with realm import
/opt/keycloak/bin/kc.sh import --file $REALM_FILE --override true

# Start Keycloak
exec /opt/keycloak/bin/kc.sh start-dev --health-enabled=true --metrics-enabled=true --log-level=INFO --import-realm