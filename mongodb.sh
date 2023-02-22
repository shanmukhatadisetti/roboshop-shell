source common.sh

print_head "Setup MongoDB repository"
cp configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
echo $?

print_head "Install MongoDB"
yum install mongodb-org -y &>>${log_file}
echo $?

print_head "Update MongoDB Listen address"
sed -i -r 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${log_file}
echo $?

print_head "Enable MongoDB"
systemctl enable mongod &>>${log_file}
echo $?

print_head "start MongoDB"
systemctl restart mongod &>>${log_file}
echo $?

