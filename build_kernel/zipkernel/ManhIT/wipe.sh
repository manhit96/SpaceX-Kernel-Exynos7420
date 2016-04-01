#!/sbin/sh

ui_print " - removing Knox"
cd /system

rm -rf *app/BBCAgent*
rm -rf *app/Bridge*
rm -rf *app/ContainerAgent*
rm -rf *app/ContainerEventsRelayManager*
rm -rf *app/DiagMonAgent*
rm -rf *app/ELMAgent*
rm -rf *app/FotaClient*
rm -rf *app/FWUpdate*
rm -rf *app/FWUpgrade*
rm -rf *app/HLC*
rm -rf *app/KLMSAgent*
rm -rf *app/*Knox*
rm -rf *app/*KNOX*
rm -rf *app/LocalFOTA*
rm -rf *app/RCPComponents*
rm -rf *app/SecKids*
rm -rf *app/SecurityLogAgent*
rm -rf *app/SPDClient*
rm -rf *app/SyncmlDM*
rm -rf *app/UniversalMDMClient*
rm -rf container/*Knox*
rm -rf container/*KNOX*

sed -i -e '/ro.securestorage.knox/c\ro.securestorage.knox=false' build.prop
sed -i -e '/ro.securestorage.support/c\ro.securestorage.support=false' build.prop
sed -i -e '/ro.config.knox/c\ro.config.knox=0' build.prop
sed -i -e '/ro.config.tima/c\ro.config.tima=0' build.prop

sync
