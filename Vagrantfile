Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"

  config.vm.define "maestro" do |maestro|
    maestro.vm.hostname = "maestro.empresa.local"
    maestro.vm.network "private_network", ip: "192.168.50.2"

    maestro.vm.provider "virtualbox" do |vb|
      vb.name = "DNS-Maestro"
      vb.memory = 1024
      vb.cpus = 1
    end

    maestro.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y bind9 bind9utils bind9-doc dnsutils vim curl tcpdump net-tools
      systemctl enable bind9
      systemctl start bind9
    SHELL
  end

  config.vm.define "esclavo" do |esclavo|
    esclavo.vm.hostname = "esclavo.empresa.local"
    esclavo.vm.network "private_network", ip: "192.168.50.3"

    esclavo.vm.provider "virtualbox" do |vb|
      vb.name = "DNS-Esclavo"
      vb.memory = 1024
      vb.cpus = 1
    end

    esclavo.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y bind9 bind9utils bind9-doc dnsutils vim curl tcpdump net-tools
      systemctl enable bind9
      systemctl start bind9
    SHELL
  end

end
