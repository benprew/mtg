Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "meerkat"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host only network IP, allowing you to access it
  # via the IP.
  config.vm.network "192.168.10.10"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port "http", 80, 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.share_folder("v-data", "/home/vagrant/src", "..", :nfs => true)
  config.vm.forward_port("web", 3000, 3000)

#### Provision with Puppet #####

  config.vm.provision :puppet, :module_path => "~/src/mtg/manifests/modules", :options => [ "--verbose" ]

#### Provision with Chef #####
# 
# 
#   # Enable provisioning with chef solo, specifying a cookbooks path (relative
#   # to this Vagrantfile), and adding some recipes and/or roles.
#   #
# 
#   config.vm.provisioner = :chef_solo
#   # Grab the cookbooks from the Vagrant files
#   config.chef.recipe_url = "http://files.vagrantup.com/getting_started/cookbooks.tar.gz"
# 
#   # Tell chef what recipe to run. In this case, the `vagrant_main` recipe
#   # does all the magic.
#   config.chef.add_recipe("vagrant_main")
# 
#   # config.chef.cookbooks_path = "cookbooks"
#   # config.chef.add_recipe "mysql"
#   # config.chef.add_role "web"
# 
#   # You may also specify custom JSON attributes:
#   # config.chef.json = { :mysql_password => "foo" }
# 
#   # Enable provisioning with chef server, specifying the chef server URL,
#   # and the path to the validation key (relative to this Vagrantfile).
#   #
#   # The Opscode Platform uses HTTPS. Substitute your organization for
#   # ORGNAME in the URL and validation key.
#   #
#   # If you have your own Chef Server, use the appropriate URL, which may be
#   # HTTP instead of HTTPS depending on your configuration. Also change the
#   # validation key to validation.pem.
#   #
#   # config.vm.provisioner = :chef_server
#   # config.chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
#   # config.chef.validation_key_path = "ORGNAME-validator.pem"
#   #
#   # If you're using the Opscode platform, your validator client is
#   # ORGNAME-validator, replacing ORGNAME with your organization name.
#   #
#   # IF you have your own Chef Server, the default validation client name is
#   # chef-validator, unless you changed the configuration.
#   #
#   # config.chef.validation_client_name = "ORGNAME-validator"
end
