#!/bin/bash

apt update -y

echo "postfix postfix/mailname string vert.iut" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt install -y postfix mailutils

echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf
systemctl restart postfix
systemctl enable postfix

apt install -y dovecot-imapd dovecot-pop3d
sed -i 's/#mail_location = .*/mail_location = maildir:~\/Maildir/' /etc/dovecot/conf.d/10-mail.conf
systemctl restart dovecot
systemctl enable dovecot

#useradd test -m

#useradd test2 -m

#sudo -u test maildirmake.dovecot /home/test/Maildir
#sudo -u test maildirmake.dovecot /home/test/Maildir/.Drafts
#sudo -u test maildirmake.dovecot /home/test/Maildir/.Sent
#sudo -u test maildirmake.dovecot /home/test/Maildir/.Trash
#chown -R test:test /home/test/Maildir

#sudo -u test2 maildirmake.dovecot /home/test2/Maildir
#sudo -u test2 maildirmake.dovecot /home/test2/Maildir/.Drafts
#sudo -u test2 maildirmake.dovecot /home/test2/Maildir/.Sent
#sudo -u test2 maildirmake.dovecot /home/test2/Maildir/.Trash
#chown -R test2:test2 /home/test2/Maildir

id -u kevin &>/dev/null || adduser --disabled-password --gecos "" kevin
id -u  minhtue &>/dev/null || adduser --disabled-password --gecos "" minhtue
id -u mohane &>/dev/null || adduser --disabled-password --gecos "" mohane
systemctl restart postfix dovecot

sudo -u kevin maildirmake.dovecot /home/kevin/Maildir
sudo -u minhtue maildirmake.dovecot /home/minhtue/Maildir
sudo -u mohane maildirmake.dovecot /home/mohane/Maildir


cat backup_10-mail_conf.txt > /etc/dovecot/conf.d/10-mail.conf
cat save_main_cfg.txt > /etc/postfix/main.cf



systemctl restart postfix dovecot

#sudo chpasswd kevin
