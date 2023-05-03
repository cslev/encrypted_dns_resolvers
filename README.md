# Publicly available encrypted DNS resolvers
Collect publicly available encrypted DNS resolvers in a parseable format.

I am pretty much interested in publicly available DoH (DNS-over-HTTPS) resolvers. Not many public lists are available, or if there is one, using it without tedious manual labor is cumbersome. 
This repository is for collecting DoH (and possibly other encrypted DoX resolvers' data, e.g., DoT, DoQ) resolvers data in an easily parseable JSON file. 

# How the data is collected
So far, there is only one credible source I found, which is the Wiki page of cURL. See it [here](https://github.com/curl/curl/wiki/DNS-over-HTTPS). However, it only contains a table of accessible resolvers, which:
 - do not include the bootstrap IP address of the resolvers
 - is easy to view with human eyes, but difficult to parse by machines effectively.

 
 I found a nice [script](https://gist.github.com/kimbo/dd65d539970e3a28a10628f15398247b) that can do some heavylifting when it comes to parsing. In fact, I am using that script to get the raw yet meaningful data from [cURL wiki](https://github.com/curl/curl/wiki/DNS-over-HTTPS). 
 
 Afterward, further scripting is done to:
  - get the bootstrap IP for the resolvers
  - prettify output
  - make it a correct JSON file

Last but not least, there is still some need for manual labor to remove duplicates and/or rename some resolvers that are shown with the same name (e.g., Quad9) but eventually have different versions (e.g., recommended, secured, unsecured, secured w/ ECS support).

Accordingly, even though I have the scripts in the `scripts/` directory, running those scripts on your own is not recommended to get the latest list of resolvers unless you know what you are doing.

# Why only cURL wiki?
I have encountered other lists of encrypted DNS resolvers, mostly from academia, as an outcome of related research.
Recently, I found [this](https://lrxgoat.github.io/). The website is quite fancy; you can get some statistics as well, but data-wise...they do not provide something which I wanted to see. 
I downloaded their [DoH data](https://lrxgoat.github.io/dataset/DOT-DOH/result_doh.txt). This list, however, only has IP addresses and flags (indicating, among many things, whether they support POST or GET, HTTPS URI ends with /dns or /dns-query,etc.).
To effectively test them, we would need the exact URL that also matches the TLS certificate's server name, or, more precisely, the SNI in the handshake.
After going through that list using reverse DNS lookups via `dig +short -x $IP`, I ended up having a lot of IP addresses not reverse-looked up correctly or at all.
The problem with reverse lookups is that you might not get the right domain name you are looking for. Especially if your service runs in some cloud service, I get something like `IP-IP-IP-IP.ip.linodeusercontent.com` domain name instead of the correct one. 
Therefore, we cannot use them directly.

The other issue with these `nmap'd/Zmap'd` service discoveries is that, just as indicated in the paper from the `lrxgoat` guys, many have expired TLS certificates. You just want a quick check with `dig`, and it already fails.

At the end of the day, I tried filtering this list of thousands of resolvers based on the success of reverse lookups, and meaningful domain names (which at least contain `doh` somewhere) and ended up having `63`resolves only. 
Tried randomly a couple of them, and they either did not work or still had expired certificates or any other problem.

Nonetheless, I decided to go with the cURL wiki only. That is a community-driven collection that, so far, was always at least 90% accurate. Cheers to the open-source community for that.

Then, my repo is more like an additional contribution to that. 

# Feel free to contribute
Git pull requests are welcome, let's make this JSON format useful and up-to-date! 


