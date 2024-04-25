package simpledb;
import java.io.*;
import java.util.*;

/**
 * HeapFile is an implementation of a DbFile that stores a collection of tuples
 * in no particular order. Tuples are stored on pages, each of which is a fixed
 * size, and the file is simply a collection of those pages. HeapFile works
 * closely with HeapPage. The format of HeapPages is described in the HeapPage
 * constructor.
 * 
 * @see simpledb.HeapPage#HeapPage
 * @author Sam Madden
 */
public class HeapFile implements DbFile {

    /**
     * Constructs a heap file backed by the specified file.
     * 
     * @param f
     *            the file that stores the on-disk backing store for this heap
     *            file.
     */
  private final File f;
  private final TupleDesc td;

  public HeapFile(File f, TupleDesc td) {
    // some code goes here
    this.f = f;
    this.td = td;
  }

  /**
   * Returns the File backing this HeapFile on disk.
   *
   * @return the File backing this HeapFile on disk.
   */
  public File getFile() {
    // some code goes here
    return f;
  }

  /**
   * Returns an ID uniquely identifying this HeapFile. Implementation note: you will need to
   * generate this tableid somewhere ensure that each HeapFile has a "unique id," and that you
   * always return the same value for a particular HeapFile. We suggest hashing the absolute file
   * name of the file underlying the heapfile, i.e. f.getAbsoluteFile().hashCode().
   *
   * @return an ID uniquely identifying this HeapFile.
   */
  public int getId() {
    // some code goes here
    return f.getAbsoluteFile().hashCode();
  }

  /**
   * Returns the TupleDesc of the table stored in this DbFile.
   *
   * @return TupleDesc of this DbFile.
   */
  public TupleDesc getTupleDesc() {
    // some code goes here
    return td;
  }

  // see DbFile.java for javadocs
  public Page readPage(PageId pid) {
    // some code goes here
    assert pid instanceof HeapPageId;
    int pageSize = BufferPool.getPageSize();
    int ofs = pageSize * pid.pageNumber();

    try {
      RandomAccessFile raf = new RandomAccessFile(f, "r");
      byte[] data = new byte[pageSize];
      raf.seek(ofs);
      raf.read(data, 0, pageSize);
      raf.close();

      return new HeapPage(((HeapPageId) pid), data);
    } catch (IOException e) {
      e.printStackTrace();
    }
    return null;
  }

  // see DbFile.java for javadocs
  public void writePage(Page page) throws IOException {
            // some code goes here
    	// not necessary for this assignment
  }

  /**
   * Returns the number of pages in this HeapFile.
   */
  public int numPages() {
    // some code goes here
    int pageSize = BufferPool.getPageSize();
    assert f.length() % pageSize == 0;
    return Math.toIntExact(f.length() / pageSize);
  }

  // see DbFile.java for javadocs
  public ArrayList<Page> insertTuple(TransactionId tid, Tuple t)
      throws DbException, IOException, TransactionAbortedException {
                // some code goes here
    	// not necessary for this assignment
        return null;
    }

  // see DbFile.java for javadocs
  public ArrayList<Page> deleteTuple(TransactionId tid, Tuple t) throws DbException,
      TransactionAbortedException {
                // some code goes here
    	// not necessary for this assignment
        return null;
  }

    // Returns a HeapFileIterator
    public DbFileIterator iterator(TransactionId tid) {
        // some code goes here
        return new HeapFileIterator(this, tid);
    }
}

/**
 * Helper class that implements the Java Iterator for tuples on
 * a HeapFile
 */
class HeapFileIterator implements DbFileIterator {
    Iterator<Tuple> it = null;
    int curpgno;

    TransactionId tid;
    HeapFile hf;

    public HeapFileIterator(HeapFile hf, TransactionId tid) {
        this.hf = hf;
        this.tid = tid;
    }

    public void open() throws DbException, TransactionAbortedException {
        // Some Code Here
        curpgno = 0;
        PageId pid = new HeapPageId(hf.getId(), curpgno);
        Page page = Database.getBufferPool().getPage(tid, pid, Permissions.READ_ONLY);
        assert page instanceof HeapPage;
        it = ((HeapPage) page).iterator();
    }

    public boolean hasNext() {
        // Some Code Here
        try {
            if (it == null) {
                return false;
            }
            if (it.hasNext()) {
                return true;
            }
            while (curpgno + 1 < hf.numPages()) {
                PageId pid = new HeapPageId(hf.getId(), ++curpgno);
                Page page = Database.getBufferPool().getPage(tid, pid, Permissions.READ_ONLY);
                assert page instanceof HeapPage;
                it = ((HeapPage) page).iterator();
                if (it.hasNext()) {
                    return true;
                }
            }
            return false;
        } catch (DbException | TransactionAbortedException e) {
            return false;
        }
    }

    // Return the next tuple in the HeapFile
    public Tuple next() throws TransactionAbortedException, DbException {
        // Some Code Here
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        assert it != null && it.hasNext();
        return it.next();
    }

    public void rewind() throws DbException, TransactionAbortedException {
        // Not needed for this assignment
    }

    public void close() {
        // Some Code Here
        curpgno = 0;
        it = null;
    }
}
