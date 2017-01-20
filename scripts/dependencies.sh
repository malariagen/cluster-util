DEBIAN_FRONTEND=noninteractive apt-get install -y etckeeper
add-apt-repository -y ppa:webupd8team/java
DEBIAN_FRONTEND=noninteractive apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true |  sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer
# Postfix mail server is also installed as a dependency
echo "postfix postfix/main_mailer_type        select  Internet Site" | debconf-set-selections

DEBIAN_FRONTEND=noninteractive apt-get install -y postfix

grep root: /etc/aliases || echo "root: sysadmin@malariagen.net" >> /etc/aliases
newaliases
echo "root root-`hostname`@malariagen.net" > /etc/postfix/canonical
postmap /etc/postfix/canonical
postconf sender_canonical_maps=hash:/etc/postfix/canonical
cat > /etc/postfix/header_checks <<+++EOF
/^To:.*@malariagen.net/  DUNNO
/^To:.*@/   DISCARD No outgoing mails allowed
+++EOF
postconf header_checks=regexp:/etc/postfix/header_checks
postconf relay_domains=malariagen.net
postfix reload

# Disable Postfix
#sudo service postfix stop
#sudo update-rc.d postfix disable
