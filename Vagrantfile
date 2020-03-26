# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7"
  # config.vm.box = "centos/7"
  # config.vm.box_version = "1803.01"

  #config.vbguest.auto_update = false
#  config.vbguest.no_remote = true


  config.vm.synced_folder "..", "/DevOps", :mount_options => ['dmode=0755', 'fmode=0774']
  config.vm.synced_folder "../..", "/workspace", :mount_options => ['dmode=0755', 'fmode=0774']

  config.vm.network "private_network", ip: "192.168.33.100"
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1536"
    vb.cpus = 2
    vb.linked_clone = true if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
  end

  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.provision "install_devbox", type: "shell", inline: <<-SHELL
    echo "Install command-line utils"
    sudo yum install -y unzip dos2unix git wget telnet nano

    echo "Add EPEL repo"
    cp /vagrant/files/epel.repo /etc/yum.repos.d/epel.repo
    cp /vagrant/files/RPM-GPG-KEY-EPEL-7 /etc/pki/rpm-gpg
    
    echo "Installing pip"
    sudo yum install -y python2-pip
    # wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
    # sudo python /tmp/get-pip.py

    sudo python -m pip install -U pip setuptools==30.2.0

    _ANSIBLE_VERSION="2.8.4"
    echo "Installing Ansible ${_ANSIBLE_VERSION} and Python libraries"
    sudo yum install -y curl gcc libffi-devel openssl-devel python-crypto python-devel python2-boto python2-cryptography
    # python-setuptools
    sudo pip install ansible==${_ANSIBLE_VERSION}

    echo "Installing AWS CLI"
    sudo pip install awscli

    echo "Installing Packer"
    mkdir /tmp/packer && cd /tmp/packer
    wget -q https://releases.hashicorp.com/packer/1.4.3/packer_1.4.3_linux_amd64.zip
    unzip packer_*.zip
    [[ -f /usr/local/bin/packer ]] && rm -rf /usr/local/bin/packer
    cp /tmp/packer/packer /usr/local/bin/packer
    chmod u+x /usr/local/bin/packer

    echo "Installing jq"
    wget -q -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    chmod +x ./jq
    mv jq /usr/bin

    echo "Installing Terraform"
    [[ -d /tmp/terraform ]] && rm -rf /tmp/terraform
    mkdir -p /tmp/terraform && cd /tmp/terraform
    #wget -q https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip
    wget -q https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
    unzip terraform_*.zip
    cp /tmp/terraform/terraform /usr/local/bin/terraform
    chmod u+x /usr/local/bin/terraform

    echo "Setting up local user files"

    homeDir=/home/vagrant
    VagrantFiles=/vagrant/files

    echo "Checking for aws credentials file"
    if [ -f $VagrantFiles/.aws/credentials ]
    then
        AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID $VagrantFiles/.aws/credentials)
        AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY $VagrantFiles/.aws/credentials)
        if [ ! -z $AWS_ACCESS_KEY_ID ] && [ ! -z $AWS_SECRET_ACCESS_KEY ]
        then
            cp $homeDir/.bash_profile /tmp/bash_profile
            if [ $(grep -o AWS_ACCESS_KEY_ID $homeDir/.bash_profile | head -n 1) ]; then sed '/AWS_ACCESS_KEY_ID/d' /tmp/bash_profile &> $homeDir/.bash_profile ; cp $homeDir/.bash_profile /tmp/bash_profile ; fi
            if [ $(grep -o AWS_SECRET_ACCESS_KEY $homeDir/.bash_profile | head -n 1) ]; then sed '/AWS_SECRET_ACCESS_KEY/d' /tmp/bash_profile &> $homeDir/.bash_profile ; cp $homeDir/.bash_profile /tmp/bash_profile; fi
            rm -rf /tmp/bash_profile
            echo "export $AWS_ACCESS_KEY_ID" >> $homeDir/.bash_profile
            echo "export $AWS_SECRET_ACCESS_KEY" >> $homeDir/.bash_profile
        else
            echo "aws credentials file found, however, it seems that keys are not defined properly"
        fi
        else
            echo "aws credentials file not found, wont assign key and secret for this instance"
    fi

    cp $VagrantFiles/.bashrc $homeDir
    dos2unix ${homeDir}/.bashrc
    chown vagrant:vagrant ${homeDir}/.bashrc && chmod 0644 ${homeDir}/.bashrc
    mkdir -p --mode=0600 ${homeDir}/.ssh
    cp $VagrantFiles/ssh-config ${homeDir}/.ssh/config

    echo "Setting spotinst sdk and ansible module"
    echo "download requests"
    sudo pip install requests
    echo "download spotinst module"
    sudo pip install spotinst
    sudo mkdir -p /usr/lib/python2.7/site-packages/ansible/modules/spotinst
    cd /usr/lib/python2.7/site-packages/ansible/modules/spotinst
    curl -O https://s3.amazonaws.com/spotinst-public/services/ansible-module/spotinst_aws_elastigroup.py
SHELL

  config.vm.provision "install_docker", type: "shell", inline: <<-SHELL
    echo "Installing Docker"
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce

    echo "Adding vagrant to docker group"
    sudo usermod -aG docker vagrant

    echo "Starting Docker"
    sudo systemctl enable docker
    sudo systemctl start docker
SHELL

end
