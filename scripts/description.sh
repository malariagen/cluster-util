for i in `awk '{print $3}' x | sed -e "s/'//g" -e "s/\\+/\\\\+/g"`
do
    echo "    - name: '$i'"
    NAME=`echo -n ${i} | sed -e 's/\+/\\\\+/g'`
    DESC=`apt-cache search $i | egrep "^${NAME}\s"`
    echo -n "      description: '"
    echo "${DESC}'"
done
