#!/bin/bash

openssl rand -base64 741 > /srv/mongodb/mongodb-keyfile
chmod 600 /srv/mongodb/mongodb-keyfile

echo "Waiting for MongoDB ReplicaSet ready.."
until [ "$(mongo --host mongo1:27017 admin --eval "printjson(rs.status())" | grep PRIMARY | head -1)" ]; do
  printf '.'
  sleep 1
done

echo $(mongo --host mongo1:27017 admin --eval "printjson(rs.status())" | grep PRIMARY | head -1)
echo "MongoDB ReplicaSet ok.."


echo SETUP.sh time now: `date +"%T" `
mongo --host mongo1:27017 <<EOF
  use admin;
  db.createUser(
    {
      user: "root",
      pwd: "Boxout!0401",
      roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
    }
  );
  db.createUser(
    {
      user: "datadog",
      pwd: "datadog",
      roles: [ { role: "clusterMonitor", db: "admin" } ]
    }
  );
  use institutebox;
  db.createUser(
    {
      user: "ibadmin",
      pwd: "Boxout!0401",
      roles: ["dbAdmin", "readWrite"]
    }
  );
EOF