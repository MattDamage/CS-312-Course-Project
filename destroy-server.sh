#!/bin/bash


#This script is primarly for dev purposes with testing from a "blank slate" however it could be usefull to have a kill switch for all the servers, so I left it in.

echo "Destroying the Minecraft Server!"
echo "All data will be lost!!!"
echo ""
terraform destroy -auto-approve

echo "done!"