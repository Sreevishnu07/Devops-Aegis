#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo bash nagios/scripts/install-core-config.sh" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_OBJECTS="${REPO_DIR}/nagios/objects/sentinel"
NAGIOS_ETC="/usr/local/nagios/etc"
NAGIOS_CFG="${NAGIOS_ETC}/nagios.cfg"
OBJECT_DIR="${NAGIOS_ETC}/objects/sentinel"
RECOVERY_CONF_DIR="/etc/sentinel"

for required in \
  "${NAGIOS_CFG}" \
  /usr/local/nagios/bin/nagios \
  /usr/local/nagios/libexec/check_http \
  /usr/lib/nagios/plugins/check_nrpe \
  "${REPO_DIR}/nagios/scripts/sentinel-recover"; do
  if [[ ! -e "$required" ]]; then
    echo "Required path is missing: $required" >&2
    echo "Verify Nagios Core, Nagios Plugins, NRPE client plugin, and repository clone." >&2
    exit 1
  fi
done

if ! id nagios >/dev/null 2>&1; then
  echo "Nagios service account 'nagios' does not exist." >&2
  exit 1
fi

read -r -p "Nagios administrator email address: " ADMIN_EMAIL
if [[ ! "$ADMIN_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
  echo "That does not look like a valid email address. No configuration was installed." >&2
  exit 1
fi

install -d -o root -g nagios -m 0750 "$OBJECT_DIR"
install -d -o root -g root -m 0755 "$RECOVERY_CONF_DIR"
install -d -o ubuntu -g ubuntu -m 0750 /var/lib/sentinel
if [[ ! -e /var/log/sentinel-recovery.log ]]; then
  install -o root -g nagios -m 0640 /dev/null /var/log/sentinel-recovery.log
fi

install -o root -g nagios -m 0640 "${SOURCE_OBJECTS}/commands.cfg" "${OBJECT_DIR}/commands.cfg"
install -o root -g nagios -m 0640 "${SOURCE_OBJECTS}/hosts.cfg" "${OBJECT_DIR}/hosts.cfg"
install -o root -g nagios -m 0640 "${SOURCE_OBJECTS}/services.cfg" "${OBJECT_DIR}/services.cfg"

cat > "${OBJECT_DIR}/contacts.cfg" <<CONTACTS
# Generated locally by install-core-config.sh. Do not commit this file.
define contact {
    use                             generic-contact
    contact_name                    sentinel-admin
    alias                           Sentinel Administrator
    email                           ${ADMIN_EMAIL}
    service_notification_period     24x7
    host_notification_period        24x7
    service_notification_options    w,u,c,r
    host_notification_options       d,u,r
    service_notification_commands   sentinel-notify-service-by-email
    host_notification_commands      sentinel-notify-host-by-email
}

define contactgroup {
    contactgroup_name   sentinel-admins
    alias               Sentinel Administrators
    members             sentinel-admin
}
CONTACTS
chown root:nagios "${OBJECT_DIR}/contacts.cfg"
chmod 0640 "${OBJECT_DIR}/contacts.cfg"

install -o root -g root -m 0750 "${REPO_DIR}/nagios/scripts/sentinel-recover" /usr/local/sbin/sentinel-recover
install -o root -g root -m 0440 "${REPO_DIR}/nagios/sudoers/nagios-sentinel-recovery" /etc/sudoers.d/nagios-sentinel-recovery
visudo -cf /etc/sudoers.d/nagios-sentinel-recovery

if [[ ! -f "${RECOVERY_CONF_DIR}/recovery.conf" ]]; then
  install -o root -g root -m 0640 "${REPO_DIR}/nagios/config/recovery.conf.example" "${RECOVERY_CONF_DIR}/recovery.conf"
  echo "Created ${RECOVERY_CONF_DIR}/recovery.conf. Review Blue/Green private IPs before enabling recovery."
fi

backup="${NAGIOS_CFG}.sentinel-backup.$(date +%Y%m%d%H%M%S)"
cp -a "$NAGIOS_CFG" "$backup"

if ! grep -Fqx "cfg_dir=${OBJECT_DIR}" "$NAGIOS_CFG"; then
  printf '\n# Sentinel custom object definitions\ncfg_dir=%s\n' "$OBJECT_DIR" >> "$NAGIOS_CFG"
fi

set_nagios_setting() {
  local key="$1" value="$2"
  if grep -qE "^[[:space:]]*${key}=" "$NAGIOS_CFG"; then
    sed -i -E "s|^[[:space:]]*${key}=.*|${key}=${value}|" "$NAGIOS_CFG"
  else
    printf '%s=%s\n' "$key" "$value" >> "$NAGIOS_CFG"
  fi
}

set_nagios_setting enable_event_handlers 1
set_nagios_setting event_handler_timeout 180

if ! /usr/local/nagios/bin/nagios -v "$NAGIOS_CFG"; then
  cp -a "$backup" "$NAGIOS_CFG"
  echo "Nagios validation failed. Restored nagios.cfg from ${backup}; review object errors before retrying." >&2
  exit 1
fi

systemctl restart nagios.service
systemctl is-active --quiet nagios.service

echo
echo "Sentinel Nagios objects installed and Nagios restarted."
echo "Local contact file: ${OBJECT_DIR}/contacts.cfg"
echo "Recovery settings: ${RECOVERY_CONF_DIR}/recovery.conf"
echo "Recovery log will be written to /var/log/sentinel-recovery.log"
if ! command -v mail >/dev/null 2>&1; then
  echo "WARNING: /usr/bin/mail is not installed. Install/configure a mail transfer agent before expecting email delivery."
fi
