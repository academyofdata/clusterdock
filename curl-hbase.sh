#commands that create an HBase table, using HBase REST server (needs to be enabled/installed if not there)
#first create a table called 'test' with a CF called 'data'
curl -v -X PUT 'http://localhost:20550/test/schema' -H "Accept: application/json" -H "Content-Type: application/json" -d '{"@name":"test","ColumnSchema":[{"name":"data"}]}'
