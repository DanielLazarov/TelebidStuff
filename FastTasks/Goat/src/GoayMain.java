import java.util.Collections;
import java.util.Scanner;
import java.util.Arrays;

//Still not working
public class GoayMain {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Scanner in = new Scanner(System.in);
		int n;
		int k;
		
		while(true){
			System.out.println("Enter the number of goats");
			n = in.nextInt();
			if(n >= 1 && n <= 1000){
				break;
			}
			else{
				System.out.println("Wrong input, enter again");
			}
		}
		int[] arr = new int[n];
		int[] checkArr = new int[arr.length];
		
		for (int i = 0; i < checkArr.length; i++) {
			checkArr[i] = 0;
		}
		
		while(true){
			System.out.println("Enter the max number of repeats");
			k = in.nextInt();
			if(k >= 1 && k <= 1000){
				break;
			}
			else{
				System.out.println("Wrong input, enter again");
			}
		}
		for (int i = 0; i < arr.length ; i++) {
			while(true){
				System.out.println("Enter a goat's weigth");
				arr[i] = in.nextInt();
				if(arr[i] >= 1 && arr[i] <= 100000){
					break;
				}
				else{
					System.out.println("Wrong input, enter again");
				}
			}
		}
		Arrays.sort(arr);
		checkNow(k,arr,checkArr);
	
	}
	
	
	
	
	public static void checkNow(int mCount, int[] arr, int[] checkArr){
		int currentSize = arr[arr.length-1];
		int count = 0;
		int currentSum = 0;
		while(true){
			count = 0;
			for (int i = arr.length-1; i >= 0; i--) {
				currentSum = 0;
				for (int j = i; j >= 0; j--) {
					if(checkArr[j] == 0){
						currentSum += arr[j];
						if(currentSum > currentSize){
						currentSum -= arr[j];					
						}
						else if(currentSum == currentSize){
							checkArr[j] = 1;
							count++;
							break;
						}
						else{
							checkArr[j] = 1;
						}
					}
					if(j == 0){
						System.out.println(currentSum);
						count++;
						break;
					}
				}								
			}
			System.out.println(count);
			if(count<=mCount){
				System.out.println("minimum boat size: " + currentSize);
				break;
			}
			else{
				for (int k = 0; k < checkArr.length; k++) {
					checkArr[k] = 0;
				}
				
			}
			//System.out.println(currentSize);
			currentSize++;
			
		}
				
	}
	
}
