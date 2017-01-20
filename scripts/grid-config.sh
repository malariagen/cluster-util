qconf -sul
for i in settings/*.user
do
qconf -Au $i
done
qconf -sul
for i in EXEC_HOSTS
do
qconf -Ae settings/$i
done
for i in SUBMIT_HOSTS
do
qconf -As settings/$i
done
qconf -spl
qconf -Msconf ./settings/scheduler
for i in settings/*_pe
do
qconf -Ap $i
done
qconf -spl

qconf -sql
for i in settings/*.q
do
qconf -Aq $i
done
qconf -sql
for i in settings/*.proj
do
qconf -Aprj $i
done
