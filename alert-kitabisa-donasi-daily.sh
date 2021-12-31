#!/bin/bash
### Request to Kitabisa API

request=`curl -s 'https://geni.ktbs.io/teras/campaigns?limit=200' \
  -H 'authority: geni.ktbs.io' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"' \
  -H 'x-ktbs-platform-name: pwa' \
  -H 'x-ktbs-time: 1640963627' \
  -H 'authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyMjgyNjksInNlY29uZGFyeV9pZCI6IjcxYjJmYTlhZjQ4NWQyNGU3ZTEyODczNzI3YWNjZTU1IiwiY2xpZW50X2lkIjoiZjcwNmUzNjI1ZjUyYTkzMzMyYjcwNjc5NzlhYWMwYzEiLCJzY29wZXMiOlsiYWxsIl0sImF1ZCI6IkF1cnVtIiwiZXhwIjoxNjQzNTU1NDAyLCJqdGkiOiIwY2RhNTVjZS1lZmNjLTQxOGMtYWVjMC0xYTI3OWVhMzk5MzAiLCJpYXQiOjE2NDA5NjM0MDJ9.BK680cnx6DoEHUGETkOrQe33fPT0Tn1ZpEamz9etObKQQ67w7EzcBn4wKQyGE3uXdg4JWkFdutGX1kAPrMXRIQ' \
  -H 'x-ktbs-api-version: 1.0.0' \
  -H 'accept: application/json' \
  -H 'x-ktbs-client-name: kanvas' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36' \
  -H 'x-ktbs-request-id: b0fb4059-176f-433a-add3-aa7c09ef3073' \
  -H 'x-ktbs-client-version: 1.0.0' \
  -H 'x-ktbs-signature: 2fb451a0574e843543f342a40cf0746a5591318324fff321d720b70f3de5de9d' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'origin: https://kitabisa.com' \
  -H 'sec-fetch-site: cross-site' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'referer: https://kitabisa.com/' \
  -H 'accept-language: en-US,en;q=0.9' \
  --compressed|jq|tee /tmp/donasi-kitabisa-hari-ini.json`

get_random_id=$(cat /tmp/donasi-kitabisa-hari-ini.json|jq '.data[].id'|shuf -n1)
cat /tmp/donasi-kitabisa-hari-ini.json|jq '.data[] | select(.id=='$get_random_id')' > /tmp/picked_campaign.json
pick_random_donation_amount=$(shuf -i 30000-50000 -n 1)
jq '. += {"random_amount_donation":"'$pick_random_donation_amount'"}' /tmp/picked_campaign.json > /tmp/picked_campaign_result.json
cat /tmp/picked_campaign_result.json


### Parsing sebelum dikirim ke telegram
amount=$(cat /tmp/picked_campaign_result.json|jq '.random_amount_donation' -r)
sort_url=$(cat /tmp/picked_campaign_result.json|jq '.short_url'  -r)
curl -s -X POST -d 'number='$amount'&language=Indonesian&lang=id&result=+' https://math.tools/calculator/numbers/words/id|grep 'placeholder="Result"' | grep -o 'readonly[^"]*<'|sed -r 's/readonly>//g'|tr -d '<'|sed -r 's/^ //g' > /tmp/terbilang.txt
terbilang=$(cat /tmp/terbilang.txt)

cat <<EOF > /tmp/message-bot-to-send.txt
Halo Bos! Jangan lupa membantu sesama hari ini!!
Saya sudah pilihkan Campaign dan Angka Donasi, berikut detailnya :

Jumlah Donasi : $amount ($terbilang)
Link Campaign : https://kitabisa.com/$sort_url

Have a great day bos!
EOF

### Sending to Telegram bot
CHAT_ID=<CHANGE WITH YOUR TELEGRAM ID>
BOT_TOKEN=<CHANGE WITH YOUR BOT TOKEN>

curl -s --data "text=$(cat /tmp/message-bot-to-send.txt)" --data "chat_id=$CHAT_ID" 'https://api.telegram.org/bot'$BOT_TOKEN'/sendMessage'
