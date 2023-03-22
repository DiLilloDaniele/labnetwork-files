#usr/bin/bash

for N in 1 2 3
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
ip netns exec r1 ip link set veth1 up
ip link set v-r12 up
ovs-vsctl add-port s2 v-r12

ip link add v-s2 type veth peer name v-s3
ip link set v-s2 netns r2
ip netns exec r2 ip link set v-s2 up
ip link set v-s3 netns r3
ip netns exec r3 ip link set v-s3 up

ip netns exec h1 ip addr add 192.168.1.1/24 dev veth0
ip netns exec r1 ip addr add 192.168.1.253/24 dev veth0
ip netns exec r1 ip addr add 192.168.2.252/24 dev veth1
#ip netns exec r1 ip addr add 192.168.1.253/24 dev veth1

ip netns exec h2 ip addr add 192.168.2.1/24 dev veth0

ip netns exec r2 ip addr add 192.168.2.253/24 dev veth0
ip netns exec r2 ip addr add 10.0.0.1/30 dev v-s2

ip netns exec r3 ip addr add 10.0.0.2/30 dev v-s3
ip netns exec r3 ip addr add 192.168.3.253/24 dev veth0
ip netns exec h3 ip addr add 192.168.3.1/24 dev veth0

ip netns exec h1 route add default gw 192.168.1.253
ip netns exec h2 route add default gw 192.168.2.253
ip netns exec h3 route add default gw 192.168.3.253

ip netns exec r1 sysctl -w net.ipv4.ip_forward=1
ip netns exec r2 sysctl -w net.ipv4.ip_forward=1
ip netns exec r3 sysctl -w net.ipv4.ip_forward=1

ip netns exec r1 ip route add 192.168.3.0/24 via 192.168.2.253 dev veth1 onlink
ip netns exec r1 ip route add 192.168.2.0/24 via 192.168.2.253 dev veth1 onlink

ip netns exec r2 ip route add 192.168.1.0/24 via 192.168.1.253 dev veth0 onlink
ip netns exec r2 ip route add 192.168.3.0/24 via 10.0.0.2

ip netns exec r3 ip route add 192.168.2.0/24 via 10.0.0.1
ip netns exec r3 ip route add 192.168.1.0/24 via 10.0.0.1