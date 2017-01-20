cat > /etc/netgroup <<+++EOF
kwiat-cluster-nodes (worker1,,) (worker2,,)
+++EOF
sed -i -e 's/netgroup:\s*nis/netgroup:\tfiles/' /etc/nsswitch.conf
#Otherwise will cause a failure if provision is run more than once
exit 0
