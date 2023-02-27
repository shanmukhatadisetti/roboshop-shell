source common.sh

mysql_root_password=$1

if [ "${mysql_root_password}" ]; then
  echo -e "\e[31mMissing MySQL Root Password Argument\e[0m"
  exit 1
fi

print_head "Set Erlang repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash

print_head "Setup RabbitMQ Repos "
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash

print_head "Install Erlang & RabbitMQ"
yum install rabbitmq-server -y

print_head "Enable RabbitMQ Service"
systemctl enable rabbitmq-server

print_head "Start RabbitMQ Service"
systemctl start rabbitmq-server

print_head "Add Application User"
rabbitmqctl add_user roboshop roboshop123

print_head "Configure Permission for App User"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"