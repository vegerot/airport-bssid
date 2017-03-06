airport-bssid
=============

Connect to a specific wifi network, based off BSSID (mac address of Access Point).

============
usage: ./Build/Release/airport-bssid &lt;ifname&gt; [&lt;bssid&gt;] [&lt;password&gt;]

- Connect to specific wireless network on <ifname> interface, provided by the access point with <bssid> and password <password>.

- If <bssid> and <password> are excluded, a scan of wireless networks from <ifname> interface is performed and a list of wireless networks are returned with ssid, bssid, channel, and signal strength details.

- Forked from https://github.com/qpSHiNqp/airport-bssid 
