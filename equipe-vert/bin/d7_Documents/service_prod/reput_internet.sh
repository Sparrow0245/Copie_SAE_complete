#!/bin/bash

sudo ip r del default via 192.168.3.190 dev eth1
sudo ip r add default via 10.0.2.2 dev eth0
