#!/bin/bash
set +x 

CONFIG=/etc/sssd/sssd.conf 
uri=`grep uri ${CONFIG}| egrep -v ^# | awk '{print $3}'`
binddn=`grep bind_dn ${CONFIG}| egrep -v ^# | awk '{print $3}'`
bindpw=`grep authtok ${CONFIG}| egrep -v ^# | awk '{print $3}'`
base=`grep base ${CONFIG}| egrep -v ^# | awk '{print $3}'`
 
TMPFILE=/tmp/$$
 
for u in `grep uri ${CONFIG}| egrep -v ^# | awk '{for (i=3; i<=NF; i++) print $i}'`
do
ldapsearch -H ${u} \
-w "${bindpw}" -D "${binddn}" \
-b "${base}" \
'(&(objectClass=posixAccount)(gidNumber=9999)(uid='"$1"'))' \
'sshPublicKey' > $TMPFILE
RESULT=$?
grep sshPublicKey:: $TMPFILE > /dev/null
if [ $? -eq 0 ]
then
 sed -n '/^ /{H;d};/sshPublicKey::/x;$g;s/\n *//g;s/sshPublicKey:: //gp' $TMPFILE | base64 -d
else
 sed -n '/^ /{H;d};/sshPublicKey:/x;$g;s/\n *//g;s/sshPublicKey: //gp' $TMPFILE
fi
  if [ $RESULT -eq 0 ]
  then 
    exit
  fi
done
rm $TMPFILE

