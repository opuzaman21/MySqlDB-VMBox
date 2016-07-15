Vagrant.configure("2") do |config|
  # MySQL 5.6.23 (matches what is running in production)
  #config.vm.provision "shell", path: "script.sh",
     # args: ["--version=5.6.23", "--rootpw=test"]
end

Vagrant::Config.run do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64"
  config.vm.host_name = "test"

  # MySQL 5.6.23 (matches what is running in production)
  config.vm.provision "shell", path: "script.sh",
      args: ["--version=5.6.23", "--rootpw=test"]
  
  # mysql guest, host
  config.vm.forward_port 3306, 3306
end
