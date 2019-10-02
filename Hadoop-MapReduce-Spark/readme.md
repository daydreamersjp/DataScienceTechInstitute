# Hadoop MapReduce Spark Ecosystem

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

### Example 1. "Hello World"-ish example

Somewhere in hadoop edge, there's a file for MapReduce example named "hadoop-mapreduce-examples-<version number>.jar" or just "hadoop-mapreduce-examples.jar". Our first task is to locate the file.
  
```command
find / -name hadoop-mapreduce-examples*
```

This command will search the file everywhere under the root directory, which potentially takes a long time and produce a lot of lines.

After finding the file use `yarn jar` command to run the program; this time I chose pi with 10 containers with 100 tasks for each.

```command
yarn jar <path to>/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 10 100
```

Successful submission will give you one Pi=3.141592....-like value in the end.

<br>

### Example 2. Count words in a text file 

Now we are more ambitious. Using the pg16328.txt, downloaded above from Gutenberg Project (https://www.gutenberg.org/ebooks/16328), I will 1) split the text into words, 2) count frequencies of words, and 3) display by order of frequncies.

Using piping of Linux command, the command would be like `cat pg16328.txt | <exectable to clean and split the text into words> | <excutable to count frequencies of words> | sort -k2 -n`. Here `sort -k2 -n` will sort the results by the second column of results in number and display on command prompt.

If I use python scripts for the exectable portions, the following two python script files to be prepared in advance.

map.py - Receive lines of text and return the tuples of (word, 1) for each word encountered. 
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

reduce.py - Sum up tuples (word, 1) generated by map.py to the total frequencies by word. 
```
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

```command
chmod 777 map.py
chmod 777 reduce.py

cat pg16328.txt | <full path to>/map.py | sort -k1 | <full path to>/reduce.py | sort -k2 -n
```

Now I will get results like this:



<br>

But wait. We did not see anything MapReduce!! Exactly. What you saw is running everything on Linux with no use of Hadoop. 

To run MapReduce, I have to use 'hadoop-streaming.jar' in `yarn jar`. Again find the 'hadoop-streaming.jar' by `find / hadoop-streaming.jar`. Then, the command is:

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

And I will get the same results as we see in Linux standalone one.

<hr>
```
  
