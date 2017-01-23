from zxadmxxx

user root

run sed -i '8,$d' /etc/yum.repos.d/tradestar-rhel54.repo
run yum clean all && yum update
run yum install -y openssh-server
run mv /APL/group01/bt /APL/group01/local
run sed -i 's|/bt$|/local|g' /TS_un/unyo/env/kiban_common_csh.env
run sed -i 's|/bt$|/local|g' /TS_un/unyo/env/kiban_common_sh.env

run useradd -d /APL/home/aplusr02 -g apl -m -s /bin/csh -u 1211 aplusr02
run useradd -d /APL/home/libran02 -g libran -m -s /bin/bash -u 1011 libran02
run mkdir /tmp/ssh
copy ssh/* /tmp/ssh/

run mkdir -p /APL/group02 && cp -r /APL/group01/pkg01 /APL/group02/pkg01 && chown -R aplusr02:apl /APL/group02/pkg01

user aplusr01
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.cshrc ~/.cshrc
run ln -s /APL/share/vim/_vimrc ~/.vimrc
run mkdir -p ~/order/tools/morning && ln -s /APL/share/shell/dummy.sh ~/order/tools/morning/morning_order.csh
run mkdir -p ~/power && ln -s /APL/share/shell/dummy.sh ~/power/morning_power.csh

user libran01
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.bashrc ~/.bashrc
run ln -s /APL/share/build_release_system ~/build_release_system
run ln -s /APL/share/vim/_vimrc ~/.vimrc

user aplusr02
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.cshrc ~/.cshrc
run ln -s /APL/share/vim/_vimrc ~/.vimrc
run mkdir -p ~/order/tools/morning && ln -s /APL/share/shell/dummy.sh ~/order/tools/morning/morning_order.csh
run mkdir -p ~/power && ln -s /APL/share/shell/dummy.sh ~/power/morning_power.csh

user libran02
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.bashrc ~/.bashrc
run ln -s /APL/share/build_release_system ~/build_release_system
run ln -s /APL/share/vim/_vimrc ~/.vimrc

user root
run echo password | passwd --stdin libran01
run echo password | passwd --stdin aplusr01
run echo password | passwd --stdin libran02
run echo password | passwd --stdin aplusr02

run echo  >> /etc/ssh/sshd_config
run echo 'AcceptEnv SJ_*' >> /etc/ssh/sshd_config

run ln -s /TS_un/tssen01 /TS_un/tssen02

run ln -s /APL/share/bin/sqlplus /usr/local/bin/sqlplus
run ln -s /APL/share/bin/sqlldr /usr/local/bin/sqlldr
