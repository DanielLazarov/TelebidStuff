import java.util.Scanner;
public class Main {	

	public static void main(String[] args) {
		double[] a = new double[1999999];
		// Get current size of heap in bytes
		long heapSize = Runtime.getRuntime().totalMemory(); 

		// Get maximum size of heap in bytes. The heap cannot grow beyond this size.// Any attempt will result in an OutOfMemoryException.
		long heapMaxSize = Runtime.getRuntime().maxMemory();

		 // Get amount of free memory within the heap in bytes. This size will increase // after garbage collection and decrease as new objects are created.
		long heapFreeSize = Runtime.getRuntime().freeMemory();
		System.out.println("size: " + heapSize + "    MaxSize: " + heapMaxSize + "    free: " + heapFreeSize);
		Scanner input = new Scanner(System.in); 
		
		System.out.println("Enter a nuber to get Factorial");
		long number = input.nextLong();
		long result = 1;
		
		long startTime = System.nanoTime();
		for (long i = 1; i <= number; i++) {
			result*=i;			
		}
		long totalTime = System.nanoTime() - startTime;
		System.out.println("loop time: " + totalTime);
		System.out.println(result);
		
		startTime = System.nanoTime();
		result = fact(number);
		totalTime = System.nanoTime() - startTime;
		System.out.println("recursive time: " + totalTime);
		System.out.println(result);
		
	}
	
	static long fact(long n)
    {
        long result;

       if(n==1)
         return 1;

       result = fact(n-1) * n;
       return result;
    }
	

}
