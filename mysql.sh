source common.sh

if[ -z "${mysql_root_password}"]; then
  echo -e "\e[31mMissing MySQL Root Password Argument\e[0m"
  exit 1
 fi
print_head "Disableing MySQL 8 Version"
dnf module disable mysql -y &>>${log_file}
status_check $?

print_head "Installing MySQL Server"
yum install mysql-community-server -y &>>${log_file}
status_check $?

print_head "Enable MySQL Service"
systemctl enable mysqld &>>${log_file}
ststus_check $?

print_head "Start MySQL Service"
systemctl start mysqld &>>${log_file}
status_check

print_head "Set Root Password"
mysql_secure_installation --set-root-pass ${mysql_root_password} &>>${log_file}
status_check $?