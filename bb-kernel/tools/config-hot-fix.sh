#!/bin/sh -e

DIR=$PWD

config_enable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xy" ] ; then
		echo "Setting: ${config}=y"
		./scripts/config --enable ${config}
	fi
}

config_disable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xn" ] ; then
		echo "Setting: ${config}=n"
		./scripts/config --disable ${config}
	fi
}

config_enable_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:# '$config' is not set:'$config'=y:g' .config
	fi
	if [ "x${test_module}" = "x${config}=m" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:'$config'=m:'$config'=y:g' .config
	fi
}

config_module_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=m"
		sed -i -e 's:# '$config' is not set:'$config'=m:g' .config
	else
		echo "$config=m" >> .config
	fi
}

config_module () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xm" ] ; then
		echo "Setting: ${config}=m"
		./scripts/config --module ${config}
	fi
}

config_string () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=\"${option}\""
		./scripts/config --set-str ${config} "${option}"
	fi
}

config_value () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=${option}"
		./scripts/config --set-val ${config} ${option}
	fi
}

cd ${DIR}/KERNEL/

#Nuke DSA SubSystem: 2020.02.20
config="CONFIG_HAVE_NET_DSA" ; config_disable
config="CONFIG_NET_DSA" ; config_disable

#SC16IS7XX breaks SERIAL_DEV_CTRL_TTYPORT, which breaks Bluetooth on wl18xx
config="CONFIG_SERIAL_SC16IS7XX_CORE" ; config_disable
config="CONFIG_SERIAL_SC16IS7XX" ; config_disable
config="CONFIG_SERIAL_SC16IS7XX_I2C" ; config_disable
config="CONFIG_SERIAL_SC16IS7XX_SPI" ; config_disable
config="CONFIG_SERIAL_DEV_CTRL_TTYPORT" ; config_enable

#WIMAX going to be removed soon...
config="CONFIG_WIMAX" ; config_disable
config="CONFIG_WIMAX_I2400M" ; config_disable
config="CONFIG_WIMAX_I2400M_USB" ; config_disable

#PHY: CONFIG_DP83867_PHY
config="CONFIG_DP83867_PHY" ; config_enable

#PRU: CONFIG_PRU_REMOTEPROC
config="CONFIG_REMOTEPROC" ; config_enable
config="CONFIG_REMOTEPROC_CDEV" ; config_enable
config="CONFIG_WKUP_M3_RPROC" ; config_enable
config="CONFIG_PRU_REMOTEPROC" ; config_module

cd ${DIR}/
