#!/bin/bash

username=$(whoami)
currenttime=$(date +"%T")
currentdate=$(date +"%D")

echo "Ad: $username"
echo "Saat: $currenttime"
echo "Tarih: $currentdate"
