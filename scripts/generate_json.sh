#!/bin/bash

ROOT="$(dirname "$0")"
source $ROOT/extra.sh


c_print "White" "Get the DoH resolvers from CURL github wiki using scrape-doh-providers.py script..."
d=$(date '+%Y%m%d')

c_print "White" "Checking python3..." 1
which python3
retval=$(echo $?)
check_retval $retval

python3 scrape-doh-providers.py 'o["name"],o["url"]' > doh_resolvers_data_curl_${d}.lst

c_print "White" "Convert downloaded data into simple csv..."
cat doh_resolvers_data_curl_${d}.lst |sed -e "s/(//g" |sed -e "s/)//g" |sed -e "s/'//g" |sed -e "s/ //g" > doh_resolvers_data_curl_${d}.csv


num_resolvers=$(cat doh_resolvers_data_curl_${d}.csv|wc -l)
output=doh_resolvers_data_${d}.json

c_print "White" "Creating JSON... ${output}"
echo "{" > $output

id=1
#percent=$(echo "scale=2;${id}/${num_resolvers}|bc -l")

for i in $(cat doh_resolvers_data_curl_${d}.csv)
do
  percent=$(echo "scale=2; ${id}/${num_resolvers}*100"|bc -l)
  echo -ne "[ processing... ] ${percent}%" $"\r" 
  
  #first row of an entry
  name=$(echo $i|cut -d ',' -f 1)
  echo -e "\t\"${name}\" : {" >> $output 
  
  # row ID
  echo -e "\t\t\"id\": ${id}," >> $output
  uri=$(echo $i|cut -d ',' -f 2)

  #row name
  echo -e "\t\t\"name\": \"${name}\"," >> $output

  #row uri
  echo -e "\t\t\"uri\": \"${uri}\"," >> $output

  #row bootstrap
  base_domain=$(echo $uri|cut -d '/' -f 3)
  # this can return more than one IP, so we make multiple bootstrap rows accordingly (if needed)
  bootstrap_id=1
  bootstrap_id_max=$(dig +short $base_domain A |grep -v '\.$' |grep -v ";;" |wc -l) #a line that starts with ;; is an error, so we remove that from the returned lines
  #in case the DNS resolution fails,i.e., no IP returned we add bootstrap_id: UNKNOWN
  #check the bootstrap_id_max, if it is 0, then no IP returned
  if [ $bootstrap_id_max -eq 0 ]
  then
    echo -e "\t\t\"bootstrap_${bootstrap_id}\": \"UNKNOWN\"" >> $output
  else
    for ip in $(dig +short $base_domain A |grep -v '\.$' |grep -v ";;") #the last grep gets rid of CNAME records
    do
      if [ $bootstrap_id -ne $bootstrap_id_max ]
      then
        #we need to print a ',' at the end if further bootstrap_ids are about to be added
        echo -e "\t\t\"bootstrap_${bootstrap_id}\": \"${ip}\"," >> $output
      else
        #after the last bootstrap id, we don't print ',' at the end
        echo -e "\t\t\"bootstrap_${bootstrap_id}\": \"${ip}\"" >> $output
      fi
      bootstrap_id=`expr $bootstrap_id + 1`
    done
  fi


  if [ $id -ne $num_resolvers ]
  then
    #we need to print additional ',' after each entry
    echo -e "\t}," >> $output
  else
    #after the last entry, we don't print ','!
    echo -e "\t}" >> $output
  fi

  #increment id 
  id=`expr $id + 1`
done
echo "}" >> $output