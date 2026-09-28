#!/bin/bash


sudo ip r del default
sudo ip r add default via 10.0.2.2 dev eth0
