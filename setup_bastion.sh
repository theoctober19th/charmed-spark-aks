# Update and Upgrade
sudo sudo apt update -y
sudo sudo apt upgrade -y

# Install essential tools
sudo snap install kubectl --classic
sudo snap install juju
mkdir -p ~/.local/share/juju
sudo snap install jhack
sudo snap install spark-client --channel 3.4/edge
