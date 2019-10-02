# Hadoop MapReduce Spark Ecosystem

<br>

## 1. Playing with HDFS
This section will give a quick playaround with HDFS file operations: downloading a file from internet and give it to HDFS and retrieve again.

<br><br>

### Step 1. Connecting to edge client computer
Contact hadoop cluster manager and get the authorization.

<br>

### Step 2. Download a file from internet
Here as an illustration, I will download a most downloaded file from Gutenberg Project, which is "Beowulf: An Anglo-Saxon Epic Poem by J. Lesslie Hall" !(https://www.gutenberg.org/ebooks/16328).

<br>

By Linux command in Edge computer,

```command
curl -O http://www.gutenberg.org/cache/epub/16328/pg16328.txt
```
