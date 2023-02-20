code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f ${log_file}

print_head() {
  echo -e "\e[35m$1\e[0m"
}

print_head "Installing nginx"
yum install nginx -y &>>${log_file}

print_head "Removing Old Content"
rm -rf /usr/share/nginx/html/* &>>${log_file}

print_head "Downloading Frontend Content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}

print_head "Extracting Downloaded Frontend"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>${log_fil}

 print_head "Copying Nginx Config for Roboshop"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}

print_head "Enableing nginx"
systemctl enable nginx &>>${log_file}

print_head "Starting nginx"
systemctl start nginx &>>${log_file}