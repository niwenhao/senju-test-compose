from zxadmxxx

user root

run sed -i '8,$d' /etc/yum.repos.d/tradestar-rhel54.repo
run yum clean all && yum update
run yum install -y openssh-server

user aplusr01
run mkdir /tmp/ssh
copy ssh/* /tmp/ssh/
run mkdir -p /APL/home/aplusr01/.ssh && cp /tmp/ssh/* /APL/home/aplusr01/.ssh/. && chmod -R go-rw /APL/home/aplusr01/.ssh

user libran01
run mkdir -p /APL/home/libran01/.ssh && cp /tmp/ssh/* /APL/home/libran01/.ssh/. && chmod -R go-rw /APL/home/libran01/.ssh
