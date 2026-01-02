systemctl enable xl2tpd.service
systemctl enable iptables.service
systemctl enable ipsec.service
systemctl enable pptpd.service
systemctl restart iptables
systemctl restart ipsec.service
systemctl restart xl2tpd.service
systemctl restart pptpd.service
