# Start Vite with host access and automatic firewall management
dev-mobile() {
  local port=${1:-5173}

  # Refresh sudo timestamp
  sudo -v

  # Open the port
  sudo ufw allow "$port/tcp" > /dev/null
  echo "Firewall: Port $port opened."

  # The trap string expands $port immediately. 
  # It also clears itself (trap - ...) to prevent double execution.
  trap "sudo ufw delete allow $port/tcp > /dev/null; echo -e '\nFirewall: Port $port closed.'; trap - INT TERM EXIT" INT TERM EXIT

  # Run dev server
  pnpm dev --host
}
