w32tm /config /manualpeerlist:"0.pool.ntp.org,0x8 1.pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time
w32tm /resync /force
w32tm /query /status
