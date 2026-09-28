#!/bin/bash 

ssh cisco@douglas09 'bash /home/cisco/service_info/scripts/douglas09.sh destroy'
ssh cisco@douglas10 'bash /home/cisco/dmz/scripts/douglas10.sh destroy'
ssh cisco@douglas11 'bash /home/cisco/service_admin/scripts/douglas11.sh destroy'

ssh cisco@douglas09 'rm -rf /home/cisco/service_info'
ssh cisco@douglas10 'rm -rf /home/cisco/dmz'
ssh cisco@douglas11 'rm -rf /home/cisco/service_admin'

ssh cisco@douglas09 'rm -rf /home/cisco/VirtualBox\ VMs/*'
ssh cisco@douglas10 'rm -rf /home/cisco/VirtualBox\ VMs/*'  
ssh cisco@douglas11 'rm -rf /home/cisco/VirtualBox\ VMs/*'