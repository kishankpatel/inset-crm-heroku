begin 
#issue while fetching go location country, issue found from May 17, 2017
#fixed by AMT
#https://github.com/alexreisner/geocoder/issues/1172
Geocoder.configure(freegeoip: {host: "freegeoip.net"})
rescue
end