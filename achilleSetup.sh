# YCSB Prep
sudo rm -rf /usr/lib/maven jdk* /usr/lib/jvm/jdk1.6.0_33
sudo yum -y update
sudo yum -y install git
wget http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz
chmod 700 apache-maven*.tar.gz
tar xzf apache-maven*.tar.gz
rm -f apache-maven*.tar.gz
sudo mv ./apache-maven*/ maven
sudo mv maven /usr/lib

#note this is the oracle version of java, replace this line
wget http://dl.dropbox.com/u/14846803/jdk-6u33-linux-x64.bin
chmod a=rwx ./jdk-6u33-linux-x64.bin
yes " " | ./jdk-6u33-linux-x64.bin
rm ./jdk-6u33-linux-x64.bin
sudo mv ./jdk1.6.0_33/ /usr/lib/jvm/jdk1.6.0_33

echo "export M2_HOME=/usr/lib/maven" >> ~/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/jdk1.6.0_33" >> ~/.bashrc
echo "export PATH=$PATH:$M2_HOME/bin:$JAVA_HOME/bin" >> ~/.bashrc
echo "export PATH=/usr/lib/maven/bin/:$PATH" >> ~/.bashrc

source ~/.bashrc

# Re-login and configure alternatives
sudo alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 2
for i in /usr/lib/jvm/*openjdk*/bin/java; do 
    echo sudo alternatives  --remove java $i; 
done
#sudo alternatives --config java

#clone ycsb
git clone https://github.com/achille/YCSB.git

cd YCSB

mvn package

#./bin/ycsb load mongodb -s -P workloads/workloada  -threads 10 | egrep -v " [0]$" 
