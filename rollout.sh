#/bin/bash

DEBIAN_FRONTEND=noninteractive

ROLLOUT_BASEDIR=/usr/local/rollout
ROLLOUT_USER=nobody
ROLLOUT_GROUP=nogroup
ROLLOUT_SAVE_PATH=/tmp/rollout

VAGRANT_PATH="/var/www/application"

echo "Updating apt ..."
apt-get update --fix-missing

echo "Installing essentials ..."
apt-get install -y --force-yes software-properties-common python-software-properties git \
                                unzip perl libnet-netmask-perl libio-socket-ssl-perl liburi-perl libwww-perl

wget -P /tmp/rollout https://github.com/dparrish/rollout/archive/master.zip
unzip $ROLLOUT_SAVE_PATH/master.zip -d $ROLLOUT_SAVE_PATH
cp $ROLLOUT_SAVE_PATH/rollout-master/rolloutd /usr/local/sbin/rolloutd
cp $ROLLOUT_SAVE_PATH/rollout-master/rollout.init /etc/init.d/rollout
cp $ROLLOUT_SAVE_PATH/rollout-master/rollout.default /etc/default/rollout
mkdir -p $ROLLOUT_BASEDIR
cp -r $ROLLOUT_SAVE_PATH/rollout-master/steps/ $ROLLOUT_BASEDIR/
cp $ROLLOUT_SAVE_PATH/rollout-master/RolloutConfigValidator.pm $ROLLOUT_BASEDIR/
cp $ROLLOUT_SAVE_PATH/rollout-master/rollout $ROLLOUT_BASEDIR/
chmod 750 /usr/local/sbin/rolloutd
chmod 755 /etc/init.d/rollout
chmod 600 /etc/default/rollout
cp $VAGRANT_PATH/rollout.cfg $ROLLOUT_BASEDIR/rollout.cfg
ln -s $VAGRANT_PATH/conf $ROLLOUT_BASEDIR/conf
ln -s $VAGRANT_PATH/fragments $ROLLOUT_BASEDIR/fragments
ln -s $VAGRANT_PATH/files $ROLLOUT_BASEDIR/files
chown -R $ROLLOUT_USER:$ROLLOUT_GROUP $ROLLOUT_BASEDIR

sed -i "s,RUN_ON_STARTUP=0,RUN_ON_STARTUP=1," /etc/default/rollout
sed -i "s,LISTEN_SSL=--ssl,#LISTEN_SSL=--ssl," /etc/default/rollout
sed -i "s,USER=nobody,USER=$ROLLOUT_USER," /etc/default/rollout
sed -i "s,GROUP=daemon,GROUP=$ROLLOUT_GROUP," /etc/default/rollout

ln -s /etc/init.d/rollout /etc/rc1.d/K20rollout
ln -s /etc/init.d/rollout /etc/rc3.d/S70rollout
ln -s /etc/init.d/rollout /etc/rc2.d/S70rollout
/etc/init.d/rollout start

ROLLOUT_SERVER="127.0.0.1"
ROLLOUTD_PORT="8000"
URL=http://$ROLLOUT_SERVER:$ROLLOUTD_PORT; wget -O- $URL/rollout | perl - -u $URL -o setup
rollout
exit 0;