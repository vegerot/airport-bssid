airport-bssid
=============

Connect to a specific wifi network, based off BSSID (mac address of Access Point).

============
usage: ./Build/Release/airport-bssid &lt;ifname&gt; [&lt;bssid&gt;] [&lt;password&gt;]

- Connect to specific wireless network on &lt;ifname&gt; interface, provided by the access point with &lt;bssid&gt; and password &lt;password&gt;.

- If &lt;bssid&gt; and &lt;password&gt; are excluded, a scan of wireless networks from &lt;ifname&gt; interface is performed and a list of wireless networks are returned with ssid, bssid, channel, and signal strength details.

- Forked from https://github.com/qpSHiNqp/airport-bssid 
