# Hadoop MapReduce Spark Ecosystem

<br>

## 1. Playing with HDFS
This section will give a quick playaround with HDFS file operations: downloading a file from internet and give it to HDFS and retrieve again.

<br>

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

Here're the basic HDFS commands with quick actual file manupulation examples. ![This cheatsheet](http://images.linoxide.com/hadoop-hdfs-commands-cheatsheet.pdf) would also help.

<br><br>

## 2. MapReduce Examples
