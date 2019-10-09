# Hadoop MapReduce Spark Ecosystem
[1. Playing with HDFS](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/Hadoop-MapReduce-Spark/readme.md#1-playing-with-hdfs)

[2. MapReduce Examples](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/Hadoop-MapReduce-Spark/readme.md#2-MapReduce-Examples)

[3. Launching Hive and create external/internal tables](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/Hadoop-MapReduce-Spark/readme.md#3-launching-hive-and-create-externalinternal-tables)

[4. Killing YARN tasks](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/Hadoop-MapReduce-Spark/readme.md#4-killing-yarn-tasks)



<br>

## 1. Playing with HDFS
This section will give a quick playaround with HDFS file operations: downloading a file from internet and give it to HDFS and retrieve again.

<br>

### Step 1. Connecting to edge client computer
Contact hadoop cluster manager and get the authorization.

<br>

### Step 2. Download a file from internet
Here as an illustration, I will download a most downloaded file from Gutenberg Project, which is "Beowulf: An Anglo-Saxon Epic Poem by J. Lesslie Hall" (https://www.gutenberg.org/ebooks/16328).

<br>

By Linux command in Edge computer,

```command
curl -O http://www.gutenberg.org/cache/epub/16328/pg16328.txt
```

Now you have a text file in home folder of your Edge computer.

<br>

### Step 3. Create a directory 'raw' in your HDFS home
Now, let's connect HDFS! To kick off command for HDFS, start with `hdfs dfs`. This time, I will create a new directory 'raw'. Here's the command.

```command
hdfs dfs -mkdir raw
```

<br>

### Step 4. Put the downloaded file to HDFS
My downloaded file 'pg16328.txt' is still on the Edge computer. I want to copy it to HDFS raw folder. Use `hdfs dfs -put <source on Edge> <targe on HDFS>` command as follows.

```command
hdfs dfs -put pg16328.txt raw
```

<br>

### Step 5. Create a copy of the file copied to HDFS raw to your HDFS home
To copy a file from somewhere in HDFS to somewhere else in HDFS, use `hdfs dfs -cp <source on HDFS> <target on HDFS>`.

```command
hdfs dfs -cp raw/pg16328.txt .
```

<br>

### Step 6. Rename the file you just copied to 'input.txt'
There's no rename command in HDFS. Instead you can use move command such like `hdfs dfs -mv <original file name> <target file name>`.

```command
hdfs dfs -mv pg16328.txt input.txt
```

<br>

### Step 7. Read input.txt
Just as Linux command, I can use `cat` command to display the content of the file.

```command
hdfs dfs -cat input.txt
```

<br>

### Step 8. Remove input.txt
Again just like Linux command, to remove a file I can use `rm`. Here I also add `-skipTrash` option which otherwise will put deleted files to '.Trash' folder, but will squeeze the disk capacity.

```command
hdfs dfs -rm -skipTrash input.txt
```

<br>

### Step 9. Retrieve input.txt from HDFS to Edge computer and rename it to 'local.txt' at the same time
Just as inverse of Step 4, I will pull the data from HDFS and locate it in Edge local, using `hdfs -dfs -get <source on HDFS> <target on Edge>`. If I just change the name of target file, I can save the file in a different name.

```command
hdfs dfs -get input.txt local.txt
```

OR using cat to stdout the text contents with receiving it at local Edge assigning a text file is also available option.

```command
hdfs dfs -cat iput.txt > local.txt
```

<br><br>

### Cheatsheet

Here're the basic HDFS commands with quick actual file manupulation examples. [This cheatsheet](http://images.linoxide.com/hadoop-hdfs-commands-cheatsheet.pdf) would also help.

<br><br>

## 2. MapReduce Examples
I will demonstrate how we can use MapReduce on Hadoop environment, using `yarn` command.

<br>

### Example 1. "Hello World"-ish example

<br>

Somewhere in hadoop edge, there's a file for MapReduce example named "hadoop-mapreduce-examples-<version number>.jar" or just "hadoop-mapreduce-examples.jar". Our first task is to locate the file.
  
```command
find / -name hadoop-mapreduce-examples*
```

This command will search the file everywhere under the root directory, which potentially takes a long time and produce a lot of lines.

After finding the file use `yarn jar` command to run the program; this time I chose pi with 10 containers with 100 tasks for each.

```command
yarn jar <path to>/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 10 100
```

<br>

Successful submission will give you one Pi=3.141592....-like (but not exactly due to the few number of simulations) value in the end.

<br>

### Example 2. Count words in a text file 

<br>

Now we are more ambitious. Using the pg16328.txt, downloaded above from Gutenberg Project (https://www.gutenberg.org/ebooks/16328), I will 1) split the text into words, 2) count frequencies of words, and 3) display by order of frequncies.

Using piping of Linux command, the command would be like `cat pg16328.txt | <exectable to clean and split the text into words> | <excutable to count frequencies of words> | sort -k2 -n`. Here `sort -k2 -n` will sort the results by the second column of results in number and display on command prompt.

If I use python scripts for the exectable portions, the following two python script files to be prepared in advance (expecting python v2, but just update `print` lines for python v3.)

<br>

"map.py"(Python ver2.x) - Receive lines of text and return the tuples of (word, 1) for each word encountered. 
```python
#!/usr/bin/env python

import sys

# input comes from STDIN (standard input)
for line in sys.stdin:
    
    # remove leading and trailing whitespace
    line = line.strip()
    
    # split the line into words
    words = line.split()
    
    for word in words:
        # write the results to STDOUT (standard output);
        # what we output here will be the input for the
        # Reduce step, i.e. the input for reducer.py
        # tab-delimited; the trivial word count is 1
        print '%s\t%s' % (word, 1)
```

<br>

"reduce.py"(Python ver2.x) - Sum up tuples (word, 1) generated by map.py to the total frequencies by word. 
```python
#!/usr/bin/env python

from operator import itemgetter
import sys

res = {}
for line in sys.stdin:

    # Clean line
    line = line.strip()
    
    # Regain (word, 1) tuples from stdin information.
    word, count = line.split('\t', 1)
    
    # In case count is converted to non-int through stdout-stdin
    try:
        count = int(count)
    except ValueError:
        continue
        
    # Sum in dictionary
    try:
        res[word] += count
    except KeyError:
        res[word] = count
        
# Output by order of frequencies
for w,c in sorted(res.items(), key=lambda (k,v): v):
    print '%s\t%s' % (w,c)
```

<br>

Note that two .py files need to be uploaded to the Edge computer.
Then, the full Linux command to run this will be:

<br>

```command
chmod 777 map.py
chmod 777 reduce.py

cat pg16328.txt | <full path to>/map.py | <full path to>/reduce.py | sort -k2 -n
```

<br>

Now I will get results like this:

<img src="MapReduceExample_wordcount.JPG" width=200>


<br>

But wait. We did not see anything MapReduce!! Exactly. What you saw is running everything on Linux with no use of Hadoop. 

To run MapReduce, use 'hadoop-streaming.jar' in `yarn jar`. Again, find first the 'hadoop-streaming.jar' by `find / hadoop-streaming.jar`. Then, the command is:

```command
yarn jar <full path to>/hadoop-streaming.jar \
	-file <full path to>/map.py \
	-mapper <full path to>/map.py \
	-file <full path to>/reduce.py \
	-reducer <full path to>/reduce.py \
	-input <full path to>/pg16328.txt \
	-output <full path to home>/python-output
hdfs dfs -cat <full path to home>/part-00000 | sort -k2 -n
```

And you will get the same results as we see in Linux standalone one.
  
<br><br>

## 3. Launching Hive and create external/internal tables

<br>

### 1. Getting ready for Beeline (command line interface to Hive)

<br>

Beeline is a command line interface support service to Hive. To launch, just run the following command on Edge.

```command
beeline -u "jdbc:hive2://<cloud path>:2181,zoo-3.<clound path>:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2;" --showDbInPrompt=true
```
<br>
 
Now the command line expects the SQL query. SQL query is more MySQL than SQL Server, and every statement should end with semi-colon ';'.

<br>

```sql
 use <database>;
```

<br>

Next, we will see how to create tables in Hive. Hive can have two types of tables: external table and internal table. 

Based on [this post](https://stackoverflow.com/questions/17038414/difference-between-hive-internal-tables-and-external-tables), the difference is:

- Use EXTERNAL tables when:

	- The data is also used outside of Hive. For example, the data files are read and processed by an existing program that doesn’t lock the files.
	- Data needs to remain in the underlying location even after a DROP TABLE. This can apply if you are pointing multiple schema (tables or views) at a single data set or if you are iterating through various possible schema.
	- Hive should not own data and control settings, directories, etc., you may have another program or process that will do those things.
	- You are not creating table based on existing table (AS SELECT).


- Use INTERNAL tables when:

	-The data is temporary.
	- You want Hive to completely manage the life-cycle of the table and data.

<br>

### 2. Create an external table

<br>

External table is created by `CREATE EXTERNAL TABLE` command as such:

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS motoharu_drivers ( driverId INT, name STRING, ssn STRING, location STRING, wagePlan STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',' 
LOCATION '<directory path with flat file>'
TBLPROPERTIES ("skip.header.line.count"="1") ;
```

<br>

### 3. Create an internal table

<br>

Here's how to create an internal table from the external table just created.

```sql
CREATE TABLE IF NOT EXISTS motoharu_drivers_in ( driverId INT, name STRING, ssn STRING, location STRING, wagePlan STRING) 
STORED AS ORC;

INSERT INTO motoharu_drivers_in SELECT * FROM motoharu_drivers;
```
  
<br><br>

## 4. Killing YARN tasks

<br>

Running MapReduce tasks or Hive tasks will not necessarily end successfully. In case of failure the task will remain as a zombie runtime and cause negative impact to the future tasks. To avoid, it is recommended to kill unnecessary tasks periodically.

<br>

To kill application tasks, first run:

```command
yarn app -list
```

<br>

Then you will find the job ID like `application_157000XXXXXXX`. Then you can kill the task by:

```command
yarn app -kill application_157000XXXXXXX
```

<br><br>

## 5. HBase 

<br>

[HBase](https://hbase.apache.org/) is a service of Apache which supports the column storage as a type of NoSQL. Here I will present how to make an HBase table, scan and delete it.

<br> 

Start HBase command line on edge command prompt with:
```command
hbase shell
```

<br>

HBase takes the column families as schema and allows any columns under the column families. See [here](http://hbase.apache.org/book.html#columnfamily) for more information. 

<br> 

To create an HBase table first define the column families with a table name. Here's an example with the table name `rating` and the column families `opinion` and `meta`.
```command
create 'rating', 'opinion', 'meta'
```

<br>

Each row needs to be unique and identified by a Rowkey. Rowkey is a key used in lexicographical way in sorting it data and storing it on its storage as a [HFile](http://hbase.apache.org/book.html#_writing_hfiles_directly_during_bulk_import) on HDFS.  

<br>

The command lines below will create 2 rows with two Rowkeys "row1" and "row2". 


<br>

<hr>
