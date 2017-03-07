DEBIAN_FRONTEND=noninteractive apt-get install -y etckeeper
add-apt-repository -y ppa:webupd8team/java
DEBIAN_FRONTEND=noninteractive apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true |  sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer
