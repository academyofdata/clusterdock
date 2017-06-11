wget https://github.com/academyofdata/data/blob/master/combined-coll.csv?raw=true
mv "combined-coll.csv?raw=true" combined-coll.csv
wget https://github.com/academyofdata/data/blob/master/1m-all.csv.gz?raw=true
mv "1m-all.csv.gz?raw=true" 1m-all.csv.gz
gunzip 1m-all.csv.gz
wget https://github.com/academyofdata/data/blob/master/combined.csv?raw=true
mv "combined.csv?raw=true" combined.csv
wget https://raw.githubusercontent.com/academyofdata/data/master/movies-with-year.csv
wget https://raw.githubusercontent.com/academyofdata/data/master/movies.csv
wget https://github.com/academyofdata/data/blob/master/movieswithtags.csv?raw=true
mv "movieswithtags.csv?raw=true" movieswithtags.csv
wget https://raw.githubusercontent.com/academyofdata/data/master/ratings.csv
wget https://github.com/academyofdata/data/blob/master/ratingswithdatetime.csv.gz?raw=true
mv "ratingswithdatetime.csv.gz?raw=true" ratingswithdatetime.csv.gz
gunzip ratingswithdatetime.csv.gz
wget https://raw.githubusercontent.com/academyofdata/data/master/users.csv
