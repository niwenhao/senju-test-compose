from niwenhao/senju_app

run groupadd -g 1001 dev
run useradd -d /home/dev -g dev -m -u 1001 dev

user root
run egrep -v '^hosts:' /etc/nsswitch.conf > /tmp/nsswitch.conf
run echo 'hosts:          files' >> /tmp/nsswitch.conf
run mv /tmp/nsswitch.conf /etc/nsswitch.conf

user dev
workdir /home/dev/SenjuTest
run mkdir -p /home/dev/.ssh && chmod 700 /home/dev/.ssh
copy id_rsa /tmp/id_rsa
run cat /tmp/id_rsa > /home/dev/.ssh/id_rsa
run chmod 600 /home/dev/.ssh/id_rsa
