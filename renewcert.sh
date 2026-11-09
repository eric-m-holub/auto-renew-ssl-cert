#!/usr/bin/expect -f

# Don't ever timeout
set timeout -1

# certbot command
spawn sudo certbot certonly --manual --preferred-challenges dns -d yourdomain.com

# Wait for prompt
expect "Press Enter to Continue"

# Capture output up to this point
set output $expect_out(buffer)

# Get the random string value from output
set filtered [exec echo $output | grep -A2 "with the following value:" | tail -n1 ]

# Add the TXT record to the domain with the random string value
set addtxtrecord [exec /root/addtxtrecord.sh $filtered 2>@1]

# Give DNS server time to update
sleep 10

# Now send "Enter" input
send "\n"
expect eof
