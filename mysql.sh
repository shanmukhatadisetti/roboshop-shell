source common.sh

if[ -z "${mysql_root_password}"]; then
  echo -e "\e[31mMissing MySQL Root Password Argument\e[0m"
  exit 1
 fi
print_head "Disableing MySQL 8 Version"
dnf module disable mysql -y
status_check $?

print_head "Installing MySQL Server"
yum install mysql-community-server -y
status_check $?

print_head "Enable MySQL Service"
systemctl enable mysqld
ststus_check $?

print_head "Start MySQL Service"
systemctl start mysqld
status_check

print_head "Set Root Password"
mysql_secure_installation --set-root-pass ${mysql_root_password}
status_check $?