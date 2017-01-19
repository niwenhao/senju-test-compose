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

user libran01
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.bashrc ~/.bashrc

user aplusr02
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.cshrc ~/.cshrc

user libran02
run mkdir -p ~/.ssh && cp /tmp/ssh/* ~/.ssh/. && chmod -R go-rw ~/.ssh && cp /TS_un/_.bashrc ~/.bashrc
