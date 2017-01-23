from zxadmxxx

user root

run sed -i '8,$d' /etc/yum.repos.d/tradestar-rhel54.repo
run yum clean all && yum update
run yum install -y openssh-server

user aplusr01
run mkdir /tmp/ssh
copy ssh/* /tmp/ssh/
run mkdir -p /APL/home/aplusr01/.ssh && cp /tmp/ssh/* /APL/home/aplusr01/.ssh/. && chmod -R go-rw /APL/home/aplusr01/.ssh && cp /TS_un/_.cshrc ~/.cshrc
run ln -s /APL/share/vim/_vimrc ~/.vimrc

user libran01
run mkdir -p /APL/home/libran01/.ssh && cp /tmp/ssh/* /APL/home/libran01/.ssh/. && chmod -R go-rw /APL/home/libran01/.ssh && cp /TS_un/_.bashrc ~/.bashrc
run ln -s /APL/share/build_release_system ~/build_release_system
run ln -s /APL/share/vim/_vimrc ~/.vimrc

user root
run echo password | passwd --stdin libran01
run echo password | passwd --stdin aplusr01

run echo  >> /etc/ssh/sshd_config
run echo 'AcceptEnv SJ_*' >> /etc/ssh/sshd_config

run ln -s /TS_un/tssen01 /TS_un/tssen02
