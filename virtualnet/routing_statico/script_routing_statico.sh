#usr/bin/bash

do
    ovs-vsctl add-br s$N
    ip netns add h$N
    ip link add veth0 type veth peer name v-h$N
    ip link set veth0 netns h$N
    ip netns exec h$N ip link set veth0 up
    ip link set v-h$N up
    ovs-vsctl add-port s$N v-h$N
    ip netns add r$N
    ip link add veth0 type veth peer name v-r$N
    ip link set veth0 netns r$N
    ip netns exec r$N ip link set veth0 up
    ip link set v-r$N up
    ovs-vsctl add-port s$N v-r$N
done

ip link add veth1 type veth peer name v-r12
ip link set veth1 netns r1
ip netns exec r12 ip link set veth1 up
ip link set v-r1 up
ovs-vsctl add port s2 v-r12

ip link add v-s2 type beth peer name v-s3
ip link set v-s2 netns r2
ip nents exec r2 ip link set v-s2 up
ip link set v-s3 netns r3
ip netns exec r3 ip link set v-s3 up
