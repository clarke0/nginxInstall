## usage
run with ./nginx-setup.sh [stable|mainline] 

## Arguments  
stable Install the latest stable release (1.28.x)
mainline Install the latest mainline release (1.29.x)

If no arugment is provided defaults to stable.

## What the script does

Installs required prerequisites
Imports and verifies the offical nginx signing key 
adds the nginx.org repository
Configures repository pinning
Installs and enables nginx

## Requirements 
For Debian systems 
11 - bullseye
12 -bookworm
13 trixie
