import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class Main {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
      //checkStack();
		fileGen(120000000l);
	    //midByte("/home/daniel/Desktop/bigAssFile");
		//System.out.println(length);
	}
	
	public static void checkStack(){
		
		StackTraceElement[] ste =  Thread.currentThread().getStackTrace();
		System.out.println(ste);
	}
	public static void fileGen(long size){
		try {
			new RandomAccessFile("/home/daniel/Desktop/bigAssFile", "rw").setLength(size);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static long fileTest(String path){
		
		File myFile = new File(path);
		long byteValue = myFile.length();
		//System.out.println(myFile.length());
		
		return byteValue;
	}

	public static void midByte(String fileName){
		long fileSize = fileTest(fileName);
		try {
    		FileInputStream inputStream = new FileInputStream(fileName); 
            long timer = System.currentTimeMillis();
            byte a[] = new byte[100000];
            long total = 0;
            int nRead = 0;
            byte result;
            boolean found = false;
            
            while((nRead = inputStream.read(a))!= -1 && !found) {
            	//System.out.println(nRead);
                total += nRead;
                if(total >= fileSize/2){
                	total -= nRead;
                	nRead = 1;
                	
                	while(nRead<=a.length){
                		if(total + nRead == fileSize/2){
                			result = a[nRead-1];
                			System.out.println("Total: " + total);
                			System.out.println("nRead: " + nRead);
                			System.out.println("file size /2: " + fileSize/2);
                			System.out.println("result: " + result);
                			found = true;
                			break;
                		}
                		
                		nRead++;
                	}
                }
             //   System.out.println("reached " + total + "bytes");
            }	

            inputStream.close();		

            //System.out.println("Read " + total + " bytes");
            System.out.println(System.currentTimeMillis() - timer);
        }
        catch(FileNotFoundException ex) {
            System.out.println(
                "Unable to open file '" + 
                fileName + "'");				
        }
        catch(IOException ex) {
            System.out.println(
                "Error reading file '" 
                + fileName + "'");					
        }
	}


}
