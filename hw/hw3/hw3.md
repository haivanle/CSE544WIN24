CSE 544 Homework 3: SimpleDB
============================

**Objectives:**

To get experience implementing the internals of a DBMS.

**Assignment tools:**

apache ant and your favorite code editor

**Assigned date:** Feb 7, 2024

**Due date:** Feb. 23, 2024

**What to turn in:**

See below.

**Starter code:**

In your `hw/hw3/starter-code` folder

Acknowledgement
---------------

This assignment comes from Prof. Sam Madden's 6.830 class at MIT.

The full series of SimpleDB assignments includes what we will do in this
homework, which is to build the basic functionality for query
processing. It also includes a number of other more complex extensions, e.g. transactions and query optimization, which
we will NOT do.

We also use this series of assignments in [CSE
444](http://courses.cs.washington.edu/courses/cse444/). 

Assignment Overview
---------------

In this assignment, you will implement pieces of a basic database management system called SimpleDB. First, you will implement the core modules required to access stored data on disk. You will then write a set of operators for SimpleDB to implement selections, joins, and (as extra credit) aggregates. The end result is a database system that can perform simple queries over multiple tables. We will not ask you to add transactions, locking, and concurrent queries because we do not have time to do the full project in 544. However, we invite you to think how you would add such functionality into the system.

SimpleDB is written in Java. We have provided you with a set of partially unimplemented classes and interfaces. You will need to write the code for these classes. Half of your grade will come from running a set of system tests written using [JUnit](http://www.junit.org/). We have also provided a number of unit tests, which we will not use for grading but that you may find useful in verifying that your code works. Note that the unit tests we provide are to help guide your implementation along, but they are not intended to be comprehensive or to establish correctness. The other half of your grade will come from a short writeup and a subjective evaluation of your code.

The remainder of this document describes the basic architecture of SimpleDB, gives some suggestions about how to start coding, and discusses how to hand in your assignment.

We **strongly recommend** that you start as early as possible on this assignment. It requires you to write a fair amount of code! 


## 0. Comfort with Programming

This assignment will require the most traditional coding of any of the assignments. In particular, you're going to write a significant amount of Java code which may be intimidating if you're not comfortable with programming. However, you don't have to use any complex techniques or paradigms, and we promise you can do it! In particular, we would recommend that people who aren't familiar with java go through at least the first few lessons of this [course](https://www.codecademy.com/courses/learn-java/) to get the basics of the syntax. You won't need to be a java whiz, just familiar enough to write some straightforward functions.

That being said, SimpleDB (which you will be modifying and filling in) is a relatively complex piece of code, and it is possible you are going to find bugs, inconsistencies, and bad, outdated, or incorrect documentation, etc. We ask you, therefore, to do this assignment with an adventurous mindset. Don't get mad if something is not clear, or even wrong; rather, try to figure it out yourself or make a post on the EdStem. We'll make sure to respond to all posts as soon as possible and push updates to the code when needed.

Lastly, we want to stress that the StackOverflow for java questions is extremely thorough! So, when you run into a java question, look for answers there, and you'll likely find some helpful hints.


## 1. Getting started

### 1.1 Environment Setup

These instructions are written for any Unix-based platform (e.g., Linux, MacOS, etc.). Because the code is written in Java, it should work under Windows as well, though the directions in this document may not apply exactly.

Start by pulling the latest changes from upstream to your local master branch 
(the upstream is the one you added per the instructions [here](https://gitlab.cs.washington.edu/cse544-2024wi/cse544-2024wi/-/blob/main/hw/README.md?ref_type=heads)).

```bash
$ git pull upstream master
```

SimpleDB uses the [Ant build tool](http://ant.apache.org/) to compile the code and run tests. Ant is similar to [make](http://www.gnu.org/software/make/manual/), but the build file is written in XML and is somewhat better suited to Java code. Most modern Linux distributions include Ant natively, but you can also find installation instructions [here](https://ant.apache.org/bindownload.cgi).

You will also need to make sure you have a Java Development Kit (JDK) installed. SimpleDB requires at least Java 8 (note that "Java 8" and "Java 1.8" refer to the same version of Java—the former is used for branding purposes).

You can install a JDK as follows:
- On macOS: `brew install openjdk@11`
- On Ubuntu (or WSL): `sudo apt install openjdk-11-jdk`
- On Windows: See this [guide](https://docs.microsoft.com/en-us/java/openjdk/install).

### 1.2 Running Ant Tests

To help you during development, we have provided a set of unit tests in addition to the system tests that we use for grading. Unit tests generally test a small portion of code while the system tests are larger end-to-end tests. These are by no means comprehensive, and you should not rely on them exclusively to verify the correctness of your project.

To run the unit tests use the test build target:

```bash
$ cd hw/hw3/starter-code
$ # run all unit tests
$ ant test
$ # run a specific unit test
$ ant runtest -Dtest=TupleTest
```

You should see output similar to:

```bash
# build output...

test:
  [junit] Running simpledb.TupleTest
  [junit] Testsuite: simpledb.TupleTest
  [junit] Tests run: 3, Failures: 0, Errors: 3, Time elapsed: 0.036 sec
  [junit] Tests run: 3, Failures: 0, Errors: 3, Time elapsed: 0.036 sec

# ... stack traces and error reports ...
```

The output above indicates that three errors occurred during
compilation; this is because the code we have given you doesn't yet
work. As you complete parts of the assignment, you will work towards
passing additional unit tests. If you wish to write new unit tests as
you code, they should be added to the test/simpledb directory.

For more details about how to use Ant, see the
[manual](http://ant.apache.org/manual/). The [Running
Ant](http://ant.apache.org/manual/running.html) section provides details
about using the ant command. However, the quick reference table below
should be sufficient for working on the assignments.

  - `ant`                              Build the default target (for simpledb, this is dist).
  - `ant -projecthelp`                 List all the targets in `build.xml` with descriptions.
  - `ant dist`                         Compile the code in src and package it in `dist/simpledb.jar`.
  - `ant test`                         Compile and run all the unit tests.
  - `ant runtest -Dtest=testname`      Run the unit test named `testname`.
  - `ant systemtest`                   Compile and run all the system tests.
  - `ant runsystest -Dtest=testname`   Compile and run the system test named `testname`.

### 1.2.1 Running end-to-end tests

We have also provided a set of end-to-end tests that will eventually be
used for grading. These tests are structured as JUnit tests that live in
the test/simpledb/systemtest directory. To run all the system tests, use
the systemtest build target:

```bash
$ ant systemtest

# ... build output ...

systemtest:

[junit] Running simpledb.systemtest.ScanTest
  [junit] Testsuite: simpledb.systemtest.ScanTest
  [junit] Tests run: 3, Failures: 0, Errors: 3, Time elapsed: 0.237 sec
  [junit] Tests run: 3, Failures: 0, Errors: 3, Time elapsed: 0.237 sec
  [junit]
  [junit] Testcase: testSmall took 0.017 sec
  [junit]   Caused an ERROR
  [junit] implement this
  [junit] java.lang.UnsupportedOperationException: implement this
  [junit]   at simpledb.HeapFile.id(HeapFile.java:46)
  [junit]   at simpledb.systemtest.SystemTestUtil.matchTuples(SystemTestUtil.java:90)
  [junit]   at simpledb.systemtest.SystemTestUtil.matchTuples(SystemTestUtil.java:83)
  [junit]   at simpledb.systemtest.ScanTest.validateScan(ScanTest.java:30)
  [junit]   at simpledb.systemtest.ScanTest.testSmall(ScanTest.java:41)

# ... more error messages ...
```

This indicates that this test failed, showing the stack trace where the
error was detected. To debug, start by reading the source code where the
error occurred. When the tests pass, you will see something like the
following:

```bash
$ ant systemtest

# ... build output ...

    [junit] Testsuite: simpledb.systemtest.ScanTest
    [junit] Tests run: 3, Failures: 0, Errors: 0, Time elapsed: 7.278 sec
    [junit] Tests run: 3, Failures: 0, Errors: 0, Time elapsed: 7.278 sec
    [junit]
    [junit] Testcase: testSmall took 0.937 sec
    [junit] Testcase: testLarge took 5.276 sec
    [junit] Testcase: testRandom took 1.049 sec

BUILD SUCCESSFUL
Total time: 52 seconds
```

### 1.2.3 Creating dummy tables

You may want to create your own tests and your own data tables to test your own implementation of SimpleDB. 
You can create any .txt file and convert it to a .dat file in SimpleDB's HeapFile format
using the command:

```bash
$ ant dist

$ java -jar dist/simpledb.jar convert file.txt N
```

where file.txt is the name of the file and N is the number of columns in
the file. Notice that file.txt has to be in the following format:

```
int1,int2,...,intN
int1,int2,...,intN
int1,int2,...,intN
int1,int2,...,intN
```

...where each intk is a non-negative integer.

To view the contents of a table, use the print command. Note that this
command will not work until later in the assignment when you've implemented `HeapFile`:

```bash
$ java -jar dist/simpledb.jar print file.dat N
```

where file.dat is the name of a table created with the convert command,
and N is the number of columns in the file.

### 1.2.4 Debugging

You can get some debug messages printed out while running tests if you
add

    -Dsimpledb.Debug

as one of the arguments to the Java VM.


### 1.2 Working in Visual Studio Code

If you want access to Java language features (e.g., a debugger, auto-complete, etc.) within VS Code, you'll need to install the Java Extension Pack. To do so, first click the "blocks" icon on the left sidebar (Ctrl-Shift-X on Windows/Linux or ⌘-Shift-X on macOS). Then, search "java extension pack" and hit install when you see the extension pack (it should be the first result).


### 1.3. Implementation hints

Before beginning to write code, we **strongly encourage** you to read
through this entire document to get a feel for the high-level design of
SimpleDB.

You will need to fill in any piece of code that is not implemented. It
will be obvious where we think you should write code (i.e. it should say something like "some code goes here"). You are welcome to
add extra private methods and/or helper classes.

In addition to the methods that you need to fill out for this
assignment, the class interfaces contain numerous methods that you need
not implement in this assignment. These will either be indicated per
class:

```java
// Not necessary for this assignment
public class Insert implements DbIterator {
```

or per method:

```java
public boolean deleteTuple(Tuple t) throws DbException {

  // Not necessary for this assignment
  return false;
}
```

The code that you submit should compile without having to modify these
methods.

At a high level, you will probably want to implement the classes in the following order for this assignment,

1. Implement the classes to manage tuples, namely `Tuple`, `TupleDesc`. We
    have already implemented `Field`, `IntField`, `StringField`, and `Type` for
    you. Since you only need to support integer and (fixed length)
    string fields and fixed length tuples, these are straightforward.
2. Implement the `Catalog` (this should be very simple).
3. Implement the `BufferPool` constructor and the `getPage()` method.
4. Implement the access methods, `HeapPage` and `HeapFile` and associated
    ID classes. A good portion of these files have already been written
    for you.
5. Implement the operator `SeqScan`.
6. At this point, you should be able to pass the `ScanTest` system test.
7. Implement the operators `Filter` and `Join` and verify
    that their corresponding tests work. The Javadoc comments for these
    operators contain details about how they should work. We have given
    you implementations of `Project` and `OrderBy` which
    may help you understand how other operators work.
8. At this point, you should be able to pass the `FilterTest` and `JoinTest` system tests.
9. (Extra credit) Implement `IntAggregator` and
    `StringAggregator`. Here, you will write the logic that
    actually computes an aggregate over a particular field across
    multiple groups in a sequence of input tuples. Use integer division
    for computing the average, since SimpleDB only supports integers.
    `StringAggegator` only needs to support the `COUNT` aggregate, since the
    other operations do not make sense for strings.
10. (Extra credit) Implement the `Aggregate` operator. As with
    other operators, aggregates implement the `DbIterator`
    interface so that they can be placed in SimpleDB query plans. Note
    that the output of an `Aggregate` operator is an aggregate
    value of an entire group for each call to `next()`, and that
    the aggregate constructor takes the aggregation and grouping fields.
11. (Extra credit) Use thre provided parse to run some queries, and
    report your query execution times.

At this point you should be able to pass all of the tests in the ant
`systemtest` target, which is the goal of this homework. Section
2 below walks you through these implementation steps and the unit tests
corresponding to each one in more detail.

### 1.4. Transactions, locking, and recovery

As you look through the interfaces that we have provided you, you will
see a number of references to locking, transactions, and recovery. You
do not need to support these features. We will not be implementing this
part of SimpleDB in 544. The test code we have provided you with
generates a fake transaction ID that is passed into the operators of the
query it runs; you should pass this transaction ID into other operators
and the buffer pool.

## 2. SimpleDB Architecture Overview

SimpleDB consists of:

-   Classes that represent fields, tuples, and tuple schemas;
-   A catalog that stores information about available tables and their
    schemas.
-   A buffer pool that caches active tuples and pages in memory and
    handles concurrency control and transactions (neither of which you
    need to worry about for this homework);
-   One or more access methods (e.g., heap files) that store relations
    on disk and provide a way to iterate through tuples of those
    relations;
-   Classes that apply predicates and conditions to tuples;
-   A collection of operator classes (e.g., select, join, insert,
    delete, etc.) that process tuples;

SimpleDB does not include many things that you may think of as being a
part of a "database." In particular, SimpleDB does not have:

-   A SQL front end or parser that allows you to type queries directly
    into SimpleDB. Instead, queries are built up by chaining a set of
    operators together into a hand-built query plan (see [Section
    2.7](#query_walkthrough)). We will provide a simple parser for use
    if you like to work on the extra credit problems (see below).
-   Views.
-   Data types except integers and fixed length strings.
-   Query optimizer.
-   Indices.

In the following sections, we describe each of the main components of
SimpleDB that you will need to implement in this homework. You should
use the exercises in this discussion to guide your implementation. This
document is by no means a complete specification for SimpleDB; you will
need to make decisions about how to design and implement various parts
of the system.

## 3. The Database Class

The Database class provides access to a collection of static objects
that are the global state of the database. In particular, this includes
methods to access the catalog (the list of all the tables in the
database), the buffer pool (the collection of database file pages that
are currently resident in memory), and the log file. You will not need
to worry about the log file in this homework. We have implemented the
Database class for you. You should take a look at this file as you will
need to access these objects.

## 4. Fields and Tuples

Tuples in SimpleDB are quite basic. They consist of a collection of
`Field` objects, one per field in the `Tuple`. `Field` is an interface
that different data types (e.g., integer, string) implement. `Tuple`
objects are created by the underlying access methods (e.g., heap files,
or B-trees), as described in the next section. Tuples also have a type
(or schema), called a *tuple descriptor*, represented by a `TupleDesc`
object. This object consists of a collection of `Type` objects, one per
field in the tuple, each of which describes the type of the
corresponding field.

**Exercise 1.** Implement the skeleton methods in:

-   `src/java/simpledb/TupleDesc.java`
-   `src/java/simpledb/Tuple.java`

At this point, your code should pass the unit tests `TupleTest` and
`TupleDescTest`. At this point, `modifyRecordId()` should fail because you
havn't implemented it yet.

## 5. Catalog

The catalog (class `Catalog` in SimpleDB) consists of a list of the
tables and schemas of the tables that are currently in the database. You
will need to support the ability to add a new table, as well as getting
information about a particular table. Associated with each table is a
`TupleDesc` object that allows operators to determine the types and
number of fields in a table.

The global catalog is a single instance of `Catalog` that is allocated
for the entire SimpleDB process. The global catalog can be retrieved via
the method `Database.getCatalog()`, and the same goes for the global
buffer pool (using `Database.getBufferPool()`).

**Exercise 2.** Implement the skeleton methods in:

-   `src/java/simpledb/Catalog.java`

At this point, your code should pass the unit tests in `CatalogTest`.

## 6. BufferPool

The buffer pool (class `BufferPool` in SimpleDB) is responsible for
caching pages in memory that have been recently read from disk. All
operators read and write pages from various files on disk through the
buffer pool. It consists of a fixed number of pages, defined by the
`numPages` parameter to the `BufferPool` constructor. For this homework,
implement the constructor and the `BufferPool.getPage()` method used by
the `SeqScan` operator. The BufferPool should store up to `numPages`
pages. You can choose your eviction policy, just make sure to justify it in the writeup.

The `Database` class provides a static method,
`Database.getBufferPool()`, that returns a reference to the single
BufferPool instance for the entire SimpleDB process.

**Exercise 3.** Implement the `getPage()` method in:

-   `src/java/simpledb/BufferPool.java`

We have not provided unit tests for BufferPool. The functionality you
implemented will be tested in the implementation of HeapFile below. 

Tips: 
- The `PageId` class provides a `tableid()` function which returns the table that the page belongs to.
- You should use the `DbFile.readPage(PageId pid)` method to access pages of a DbFile.

## 7. HeapFile access method

Access methods provide a way to read or write data from disk that is
arranged in a specific way. Common access methods include heap files
(unsorted files of tuples) and B-trees; for this assignment, you will
only implement a heap file access method, and we have written some of
the code for you.

A `HeapFile` object is a set of pages, each of which
consists of a fixed number of bytes for storing tuples, (defined by the
constant `BufferPool.PAGE_SIZE`), including a header. In SimpleDB, there
is one `HeapFile` object for each table in the database. Each page in a
`HeapFile` is arranged as a set of slots, each of which can hold one
tuple (tuples for a given table in SimpleDB are all of the same size).
In addition to these slots, each page has a header that consists of a
bitmap with one bit per tuple slot. If the bit corresponding to a
particular tuple is 1, it indicates that the tuple is valid; if it is 0,
the tuple is invalid (e.g., has been deleted or was never initialized.)
Pages of `HeapFile` objects are of type `HeapPage` which implements the
`Page` interface. Pages are stored in the buffer pool but are read and
written by the `HeapFile` class.

SimpleDB stores heap files on disk in more or less the same format they
are stored in memory. Each file consists of page data arranged
consecutively on disk. Each page consists of one or more bytes
representing the header, followed by the
`BufferPool.PAGE_SIZE - # header bytes ` bytes of actual page content.
Each tuple requires *tuple size* \* 8 bits for its content and 1 bit for
the header. Thus, the number of tuples that can fit in a single page is:

`     tupsPerPage = floor((BufferPool.PAGE_SIZE * 8) / (tuple size * 8 + 1))`

Where *tuple size* is the size of a tuple in the page in bytes. The idea
here is that each tuple requires one additional bit of storage in the
header. We compute the number of bits in a page (by mulitplying
`PAGE_SIZE` by 8), and divide this quantity by the number of bits in a
tuple (including this extra header bit) to get the number of tuples per
page. The floor operation rounds down to the nearest integer number of
tuples (we don't want to store partial tuples on a page!)

Once we know the number of tuples per page, the number of bytes required
to store the header is simply:

`      headerBytes = ceiling(tupsPerPage/8)`

The ceiling operation rounds up to the nearest integer number of bytes
(we never store less than a full byte of header information.)

The low (least significant) bits of each byte represents the status of
the slots that are earlier in the file. Hence, the lowest bit of the
first byte represents whether or not the first slot in the page is in
use. Also, note that the high-order bits of the last byte may not
correspond to a slot that is actually in the file, since the number of
slots may not be a multiple of 8. Also note that all Java virtual
machines are [big-endian](http://en.wikipedia.org/wiki/Endianness).

***Note: To make this implementation a bit easier, we have provided the constructor for a HeapPage which takes an array of bytes and reads them into header and tuple arrays. So, for HeapPage, you should not need to deal with the details of the page layout.***


**Exercise 4.** Implement the skeleton methods in:

-   `src/java/simpledb/RecordId.java`
-   `src/java/simpledb/HeapPage.java`

Although you will not use them directly in this lab, we ask you to
implement `getNumEmptySlots()` and `isSlotUsed()` in `HeapPage`. These
require pushing around bits in the page header. You may find it helpful
to look at the other methods that have been provided in `HeapPage` or in
`src/java/simpledb/HeapFileEncoder.java` to understand the layout of
pages.

You will also need to implement an Iterator over the tuples in the page,
which may involve an auxiliary class or data structure.

At this point, your code should pass the unit tests in `HeapPageIdTest`,
`RecordIdTest`, and `HeapPageReadTest`.

After you have implemented `HeapPage`, you will write methods for
`HeapFile` in this homework to calculate the number of pages in a file
and to read a page from the file. You will then be able to fetch tuples
from a file stored on disk.

**Exercise 5.** Implement the skeleton methods in:

-   `src/java/simpledb/HeapFile.java`

To read a page from disk, you will first need to calculate the correct
offset in the file. Hint: you will need random access to the file in
order to read and write pages at arbitrary offsets. You should not call
BufferPool methods when reading a page from disk.

You will also need to implement the `HeapFile.iterator()` method, which
should iterate through through the tuples of each page in the HeapFile.
The iterator must use the `BufferPool.getPage()` method to access pages
in the `HeapFile`. This method loads the page into the buffer pool. Do
not load the entire table into memory on the `open()` call -- this will
cause an out of memory error for very large tables. Further, you'll want to use the iterator from `HeapPage` to iterate through the tuples on a page.

At this point, your code should pass the unit tests in `HeapFileReadTest`.

Tips:
- The `RecordId` class should be very simple, and it's very similar in implementation to the `HeapPageId` class.
- The relationship between `BufferPool` and `HeapFile` is a bit confusing because they call each other, so we want to spell it out clearly here. `BufferPool` calls the `HeapFile.readPage` function when it is asked for a page which is not present in memory. `HeapFile` calls `BufferPool.getPage()` when iterating through the file.
- When implementing the `HeapFile.readPage` function, you will need to read the correct span of bytes from the file and provide an array of those bits to the `HeapPage` constructor. For this, we recommend using the `RandomAccessFile` class from the standard library.

## 9. Operators

Operators are responsible for the actual execution of the query plan.
They implement the operations of the relational algebra. In SimpleDB,
operators are iterator based; each operator implements the `DbIterator`
interface.

Operators are connected together into a plan by passing lower-level
operators into the constructors of higher-level operators, i.e., by
'chaining them together.' Special access method operators at the leaves
of the plan are responsible for reading data from the disk (and hence do
not have any operators below them).

At the top of the plan, the program interacting with SimpleDB simply
calls `getNext` on the root operator; this operator then calls `getNext`
on its children, and so on, until these leaf operators are called. They
fetch tuples from disk and pass them up the tree (as return arguments to
`getNext`); tuples propagate up the plan in this way until they are
output at the root or combined or rejected by another operator in the
plan.

### 9.1. Scan

**Exercise 6.** Implement the skeleton methods in:

-   `src/java/simpledb/SeqScan.java`

This operator sequentially scans all of the tuples from the pages of the
table specified by the `tableid` in the constructor. This operator
should access tuples through the `DbFile.iterator()` method.

At this point, you should be able to complete the `ScanTest` system test.
Good work!

### 9.2. Filter and Join

Recall that SimpleDB DbIterator classes implement the operations of the
relational algebra. You will now implement two operators that will
enable you to perform queries that are slightly more interesting than a
table scan.

-   *Filter*: This operator only returns tuples that satisfy a
    `Predicate` that is specified as part of its constructor. Hence, it
    filters out any tuples that do not match the predicate.
-   *Join*: This operator joins tuples from its two children according
    to a `JoinPredicate` that is passed in as part of its constructor.
    We only require a simple nested loops join, but you may explore more
    interesting join implementations like hash or merge join. Describe your implementation in
    your writeup.

**Exercise 7.** Implement the skeleton methods in:

-   `src/simpledb/Predicate.java`
-   `src/simpledb/JoinPredicate.java`
-   `src/simpledb/Filter.java`
-   `src/simpledb/Join.java`

At this point, your code should pass the unit tests in `PredicateTest`,
`JoinPredicateTest`, `FilterTest`, and `JoinTest`. Furthermore, you should be
able to pass the system tests `FilterTest` and `JoinTest`.

## 9. Extra Credit

If you've done all the previous sections, then congrats! You're done with the assignment if you'd like to be. However, if you're enjoying SimpleDB, then you can continue on and implement some of the more complex operators for extra credit.

### 9.1. Aggregates (EXTRA CREDIT)

**All the materials in this section is optional and will count only as
extra credit.**

An additional SimpleDB operator implements basic SQL aggregates with a
`GROUP BY` clause. You should implement the five SQL aggregates
(`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) and support grouping. You only
need to support aggregates over a single field, and grouping by a single
field.

In order to calculate aggregates, we use an `Aggregator` interface which
merges a new tuple into the existing calculation of an aggregate. The
`Aggregator` is told during construction what operation it should use
for aggregation. Subsequently, the client code should call
`Aggregator.mergeTupleIntoGroup()` for every tuple in the child
iterator. After all tuples have been merged, the client can retrieve a
DbIterator of aggregation results. Each tuple in the result is a pair of
the form `(groupValue, aggregateValue)`, unless the value of the group
by field was `Aggregator.NO_GROUPING`, in which case the result is a
single tuple of the form `(aggregateValue)`.

Note that this implementation requires space linear in the number of
distinct groups. For the purposes of this homework, you do not need to
worry about the situation where the number of groups exceeds available
memory.

**Exercise 8.** Implement the skeleton methods in:

-   `src/simpledb/IntegerAggregator.java`
-   `src/simpledb/StringAggregator.java`
-   `src/simpledb/Aggregate.java`

At this point, your code should pass the unit tests
`IntegerAggregatorTest`, `StringAggregatorTest`, and `AggregateTest`.
Furthermore, you should be able to pass the `AggregateTest` system test.

### 9.2. Query Parser and Contest (EXTRA CREDIT)

**All the materials in this section is optional and will count only as
extra credit.**

We've provided you with a query parser for SimpleDB that you can use to
write and run SQL queries against your database once you have completed
the exercises in this homework.

The first step is to create some data tables and a catalog. Suppose you
have a file `data.txt` with the following contents:

    1,10
    2,20
    3,30
    4,40
    5,50
    5,50

You can convert this into a SimpleDB table using the `convert` command
(make sure to type `ant` first!):

    java -jar dist/simpledb.jar convert data.txt 2 "int,int"

This creates a file `data.dat`. In addition to the table's raw data, the
two additional parameters specify that each record has two fields and
that their types are `int` and `int`.

Next, create a catalog file, `catalog.txt`, with the follow contents:

    data (f1 int, f2 int)

This tells SimpleDB that there is one table, `data` (stored in
`data.dat`) with two integer fields named `f1` and `f2`.

Finally, invoke the parser. You must run java from the command line (ant
doesn't work properly with interactive targets.) From the `simpledb/`
directory, type:

    java -jar dist/simpledb.jar parser catalog.txt

You should see output like:

    Added table : data with schema INT(f1), INT(f2),
    SimpleDB>

Finally, you can run a query:

    SimpleDB> select d.f1, d.f2 from data d;
    Started a new transaction tid = 1221852405823
     ADDING TABLE d(data) TO tableMap
         TABLE HAS  tupleDesc INT(d.f1), INT(d.f2),
    1       10
    2       20
    3       30
    4       40
    5       50
    5       50

     6 rows.
    ----------------
    0.16 seconds

    SimpleDB>

The parser is relatively full featured (including support for SELECTs,
INSERTs, DELETEs, and transactions), but does have some problems and
does not necessarily report completely informative error messages. Here
are some limitations to bear in mind:

-   You must preface every field name with its table name, even if the
    field name is unique (you can use table name aliases, as in the
    example above, but you cannot use the AS keyword.)
-   Nested queries are supported in the WHERE clause, but not the FROM
    clause.
-   No arithmetic expressions are supported (for example, you can't take
    the sum of two fields.)
-   At most one GROUP BY and one aggregate column are allowed.
-   Set-oriented operators like IN, UNION, and EXCEPT are not allowed.
-   Only AND expressions in the WHERE clause are allowed.
-   UPDATE expressions are not supported.
-   The string operator LIKE is allowed, but must be written out fully
    (that is, the Postgres tilde [\~] shorthand is not allowed.)

**Exercise 9: Please execute the three queries below using your SimpleDB
prototype and report the times in your homework write-up.**

We have built a SimpleDB-encoded version of the DBLP database; the
needed files are located at:
[http://www.cs.washington.edu/education/courses/cse544/15au/hw/hw2/dblp\_data.tar.gz](http://www.cs.washington.edu/education/courses/cse544/15au/hw/hw2/dblp_data.tar.gz)

You should download the file and unpack it. It will create four files in
the `dblp_data` directory. Move them into the `simpledb` directory. The
following commands will acomplish this, if you run them from the
`simpledb` directory:

```bash
    $ wget http://www.cs.washington.edu/education/courses/cse544/15au/hw/hw2/dblp_data.tar.gz
    $ tar xvzf dblp_data.tar.gz
    $ mv dblp_data/* .
    $ rm -r dblp_data.tar.gz dblp_data
```

You can then run the parser with:
```bash
    $ java -jar dist/simpledb.jar parser dblp_simpledb.schema
```
We will start a thread on the course message board inviting anyone
interested to post their runtimes for the following three queries
(please run the queries on a lab machine and indicate which one you used
so it becomes easier to compare runtimes). The contest is just for fun.
It will not affect your grade:

1. 

    SELECT p.title
    FROM papers p
    WHERE p.title LIKE 'selectivity';

2. 

    SELECT p.title, v.name
    FROM papers p, authors a, paperauths pa, venues v
    WHERE a.name = 'E. F. Codd'
    AND pa.authorid = a.id
    AND pa.paperid = p.id
    AND p.venueid = v.id;

3.  

    SELECT a2.name, count(p.id)
    FROM papers p, authors a1, authors a2, paperauths pa1, paperauths pa2
    WHERE a1.name = 'Michael Stonebraker'
    AND pa1.authorid = a1.id
    AND pa1.paperid = p.id
    AND pa2.authorid = a2.id
    AND pa1.paperid = pa2.paperid
    GROUP BY a2.name
    ORDER BY a2.name;


Note that each query will print out its runtime after it executes.

You may wish to create optimized implementations of some of the
operators; in particular, a fast join operator (e.g., not nested loops)
will be essential for good performance on queries 2 and 3.

There is currently no optimizer in the parser, so the queries above have
been written to cause the parser to generate reasonable plans. Here are
some helpful hints about how the parser works that you may wish to
exploit while running these queries:

-   The table on the left side of the joins in these queries is passed
    in as the first `DbIterator` parameter to `Join`.
-   Expressions in the WHERE clause are added to the plan from top to
    bottom, such that first expression will be the bottom-most operator
    in the generated query plan. For example, the generated plan for
    Query 2 is:

        Project(Join(Join(Filter(a),pa),p))

Our reference implementation can run Query 1 in about .35 seconds, Query
2 in about 10 seconds, and Query 3 in about 20 seconds. We implemented a
special-purpose join operator for equality joins but did little else to
optimize performance. Actual runtimes might vary depending on your
machine setting.

Depending on the efficiency of your implementation, each of these
queries will take seconds to minutes to run to completion, outputting
tuples as they are computed. Certainly don't expect the level of
performance of postgres. :)

## Turn in instructions

You must submit your code (see below) as well as a short (2 pages,
maximum) writeup file called `writeup.pdf` describing your approach. This writeup should:

-   Describe any design decisions you made. For example any class or
    complex data structure you add to the project. If you used something
    other than a nested-loops join, describe the tradeoffs of the
    algorithm you chose.
-   Discuss and justify any changes you made to the API.
-   Describe any missing or incomplete elements of your code.
-   Describe how long you spent on the assignment, and whether there was
    anything you found particularly difficult or confusing.

At the end of this assignment, you should have a `writeup.pdf` in your submission folder, and you should have altered the code in the `start-code` folder so that it passes the system tests. Remember to push your changes to gitlab!

## Grading

50% of your grade will be based on whether or not your code passes the
system test suite. Before handing in your code, you should make
sure that it produces no errors (passes all of the tests) from both ant test and ant systemtest.

**Important**: You should be careful about changing the APIs. You should
test that your code compiles the unmodified tests. In other words, we
will clone your repository, compile it, and grade it. It will look roughly like this:

```bash
$ git clone [your-repo]
$ cd ./hw3/starter-code
$ ant test
$ ant systemtest
```

An additional 50% of your grade will be based on the quality of your
writeup and our subjective evaluation of your code.

Extra credit: 5% for each.

We hope you will enjoy this assignment and will learn a lot about how a
simple DBMS system can be implemented!
