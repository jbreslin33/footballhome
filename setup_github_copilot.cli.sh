# 1. Update and install Node.js (if not already on v22+)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 2. Install the Copilot CLI globally
sudo npm install -g @github/copilot-cli

# 3. Authenticate with your GitHub account
copilot auth login
