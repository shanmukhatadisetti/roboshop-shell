source common.sh

print_head "Setup MongoDB repository"
cp configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}

print_head "Install MongoDB"
yum install mongodb-org -y &>>${log_file}

print_head "Enable MongoDB"
systemctl enable mongod &>>${log_file}

print_head "start MongoDB"
systemctl start mongod &>>${log_file}

#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf
