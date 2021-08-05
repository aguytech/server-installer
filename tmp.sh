update-alternatives --set editor /usr/bin/vim.basic

zfs umount root/vm/sp/stock/containers/alpine314

_lxc_exec() { lxc exec ${1} -- sh -c "$2"; }

echo "nameserver 127.0.0.53
options edns0 trust-ad
#search lxd
#nameserver 213.186.33.99" > /etc/resolv.conf

echo "nameserver 2001:41d0:3:163::1
nameserver 213.186.33.99
search lxd
" > /etc/resolv.conf


####################################  RESOLVECTL

resolvectl status
resolvectl status lxdbr0
resolvectl dns
resolvectl domain

resolvectl dns lxdbr0 10.0.0.1
resolvectl domain lxdbr0 ‘lxd’

dig @10.0.0.1 A c1.lxd