//==============================================
//
// NAME: DJ  BROWN!!!!
//
//==============================================



	//==============================================
	// DATA SECTION
	//==============================================

	.section .data
IDin:	.asciz	 "Enter a number: "
	.align 3

Outn:	.asciz	"n = %d\n"
	.align 3

Crestr:	.asciz	"Creating 2 arrays of %d values each.\n"
	.align 3

IDnum:	.asciz	"%d"
	.align 3

nline:	.asciz	"\n"
	.align 3

tab_n:	.asciz	"%d\t"
	.align 3

arrstr:	.asciz	"%5d"
	.align 3

oriarr:	.asciz "The original array is:\n"
	.align 3

sortarr:.asciz "The sorted duplicated array is:\n"
	.align 3

avgstr:	.asciz "The average of the duplicate array is: %d\n"
	.align 3


	//==============================================
	// BSS SECTION
	//==============================================
	.section .bss
n:	.skip 4
n_16:	.skip 4
key:	.skip 4


	//==============================================
	// MAIN FUNCTION
	//==============================================
	.section .text
	.global main
	.type main, @function  //specify main as a function

main:
	// prolog for main
	stp	x29, x30, [sp, #-16]!   //Saving link for main
	mov	x30, sp

	// Input ID number
	// print("Enter the last digit of your TCU ID number: ")
	adr 	x0, IDin
        bl 	printf

	// input(n)
	adr	x0, IDnum
	adr	x1, n
	bl	scanf

	// if TCUID is even, n=56, else n=53
if_ID:
	adr	x1, n
	ldr	w0, [x1]
	and	w0,w0,#1
	cmp	w0,#1      //(n and 1)-1
	bge	IDodd

	// ID is even
	mov	w0, #56
	str	w0, [x1]
	b 	endIf_ID

IDodd:	// ID is odd
	mov	w0, #53
	str	w0, [x1]

endIf_ID:

	//print('\n')
        adr     x0, nline
        bl      printf

	//==> printf('Creating 2 arrays of %d values each.\n', n)
	adr	x0, Crestr
	adr	x1, n
	ldr	w1, [x1]
	bl	printf

	//print('\n')
	adr	x0, nline
	bl	printf

	//==> Allocate the stack for the array
	// by n*16 (or n_16)
	adr	x1, n
	ldr	w1, [x1]
	lsl	w1, w1, #4  //Left shift by 4 (multiply 16)
	adr	x2, n_16
	str	w1, [x2]

	// Create the storage for n integers in the stack
	adr	x1, n_16
	ldr	w1, [x1]
	sub	sp, sp, w1	//Minus n_16=n*16

	//==> Call init_array
	mov	x0, sp		// load adress of array to x0
	adr	x1, n
	ldr	w1, [x1]	// load value n to x1
	bl	init_array	// call function init_array

	// print("The original array is:\n")
	adr	x0, oriarr
	bl	printf

	//==> Call print_array
	mov     x0, sp          // load adress of array to x0
        adr     x1, n
        ldr     w1, [x1]        // load value n to x1
        bl      print_array      // call function print_array

	//print('\n')
        adr     x0, nline
        bl      printf

	//==> Allocate the stack for the copy array by n*16
	adr     x3, n_16
        ldr     x3, [x3]
        sub     sp, sp, x3      //Minus n_16=n*16 one more time

	//==> Call copy_array
	mov	x0, sp		//assign address of dest[]
	add	sp, sp, x3
	mov	x1, sp		//assign address of src[]
	sub	sp, sp, x3
	adr	x2, n
	ldr	w2, [x2]
	bl	copy_array

	// print("The sorted duplicate array is:\n")
        adr     x0, sortarr
        bl      printf

	// ==> Call selection_sort
	mov	x0, sp
	adr	x1, n
	ldr	w1, [x1]	// load value n to w1
	bl	selection_sort

	//==> Call print_array
        mov     x0, sp          // load adress of array to x0
        adr     x1, n
        ldr     w1, [x1]        // load value n to x1
        bl      print_array      // call function print_array

	// print("\n")
	adr	x0, nline
	bl	printf

	//==> Call average
	mov	x0, sp
	adr	x1, n
	ldr	w1, [x1]
	bl	average

	// print("The average of the duplicate array is: %d\n")
	mov	x1, x0
	adr	x0, avgstr
	bl	printf

	// remove the space for array in the stack
        adr 	x1, n_16
        ldr 	x1, [x1]
        add 	sp, sp, x1
	add	sp, sp, x1

	// epilog for main
	ldp	x29, x30, [sp], #16
	ret
	
	//===================================================================
	// INIT ARRAY FUNCTION
	//===================================================================
	// void init_array(int arr[], int n)
	// Initialize array 'arr' with 'n' random integers in the range [1..99].
	// Input: arr: address of array
	//          n: size of the array
	// Return: none (void)
	.type init_array, @function
init_array:

	// prolog	
	stp	x29, x30, [sp, #-16]!   //Saving link for func
	mov	x29, sp

	// function body
	stp	x0, x1, [sp, #-16]! //push arr[] and n
	
	mov 	x0, #0
	bl 	time
	bl 	srand

	stp 	x20, x21, [sp, #-16]! 	//push x20(arr[]) and x21(n)
	str	x19, [sp, #-16]!	//push x19(index)

	mov	x19, #0			//sets index to 0
		
	ldr	x21, [sp, #40] //Load n into x21
	ldr	x20, [sp, #32] //load arr[] into x20
	
	loop:
		cmp	x19, x21
		bge	endloop

		bl rand			//call rand -> result is in w0

		and w0, w0, #0xFF	//limits rand to only 0-255

		//mov    w11, #100	//limits rand to only 0-99
		//udiv   w12, w0, w11     // w12 = rand / 100
		//msub   w0, w12, w11, w0 // w0 = rand % 100 (0-99)

		str w0, [x20, x19, lsl 2] //stores rand value into arr[i]
		
		add x19, x19, #1
		b loop
	endloop:

	ldr	x19, [sp], #16
	ldp	x20, x21, [sp], #16
	ldp	x0, x1, [sp], #16
	
	// epilog
	ldp	x29, x30, [sp], #16
	ret

	//===================================================================
	// PRINT ARRAY FUNCTION
	//===================================================================
	// void print_array(int arr[], int n)
	// Print 'n' values from array 'arr' to standard output.  
	// Values will be tab delimited. 	
	// Input:  src: address of array
	//           n: size of the array
	// Return: none (void)

	.type print_array, @function
print_array:

	// prolog
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp

	// function body
	stp	x0, x1, [sp, #-16]!	//push arr[] and n
	stp	x20, x21, [sp, #-16]!	//push x20(arr[]) and x21(n)
	stp	x19, x22, [sp, #-16]!	//push x19(index) and x22(line counter)
	
	mov	x19, #0		//set index to 0
	mov 	x22, #0		//set counter to 0
	mov	x21, x1	//load n	
	mov	x20, x0	//load arr[]

	print:
		cmp	x19, x21
		bge	endprint

		adr x0, arrstr			//prepares message
		ldr w1, [x20, x19, lsl 2]	//load arr[i] into w1
		bl printf			//prints arr[i]
								
		add x19, x19, #1	//increment index
		add x22, x22, #1	//increment counter
	
		cmp x22, #5		//if counter == 5 print nline
		bne print
		
		adr x0, nline
		bl printf
		mov x22, #0
		
		b print
	endprint:
		
	ldp	x19, x22, [sp], #16
	ldp	x20, x21, [sp], #16
	ldp	x0, x1, [sp], #16
		
	// epilog
	ldp	x29, x30, [sp], #16
        ret

	//===================================================================
	// COPY ARRAY FUNCTION 
	//===================================================================
        // void copy_array(int dest[], int src[], int n)
	// Copy 'n' values from array 'src' to array 'dest'
	// Input: dest: address of array
	//         src: address of array
	//           n: size of the arrays
	// Return: none (void)
	.type copy_array, @function
copy_array:

        // prolog
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp

	// function body
	
	mov	x9, #0	//set index to 0
	copy:
		cmp	x9, x2
		bge	endcopy

		ldr 	w10, [x1, x9, lsl 2]	//load arr1[i] into w10
		str	w10, [x0, x9, lsl 2]	//store w10 into arr2[i]
	
		add	x9, x9, #1		//increment index
		b copy
	endcopy:
	// epilog
	ldp	x29, x30, [sp], #16
        ret



	//===================================================================
	// SWAP TWO INTEGERS FUNCTION
	//===================================================================
	// void swap(int *a, int *b)
	// Swap the value of two variables passed by reference.
	// Input: *a: address of integer a
	//        *b: address of integer b
	// Return: none (void)
	.type	swap, @function
swap:
	// prolog
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp

	// function body
	ldr	w10, [x0]	//load x0 and x1 into w10 and w11 respectfully
	ldr	w11, [x1]

	str	w11, [x0]	//store w10 and w11 into x1 and x0 respectfully
	str	w10, [x1]

	// epilog
	ldp	x29, x30, [sp], #16
	ret

	
	//===================================================================
	// SELECTION SORT FUNCTION 
	//===================================================================
	// void selection_sort(int arr[], int n)
	// Sort array 'arr' of size 'n' using selection sort.
	// Input: arr: address of array
	//          n: size of the array
	// Return: none (void)
	// WARNING TO SELF: DO NOT USE X10 NOR X11 - (They are used by swap...)
	.type	selection_sort, @function
selection_sort:

	// prolog
	stp	x29, x30, [sp, #-16]!
	mov 	x29, sp

	// function body

	mov	x17, x0	//placing arr[] into x17
	mov	x18, x1	//placing n into x18

	mov	x8, #0	// x8 = i
	
	sort:
		sub	x12, x18, #1 	//x12 = n-1
		cmp	x8, x12		//if i >= n-1, then endsort
		bge	endsort	
		
		//assume pos i has min element
		mov	x15, x8 	//x15 = min_index = i

		add	x9, x8, #1	//x9 = j = i + 1
		
		
		sloop:
			cmp	x9, x18		//if j >= n, then endloop
			bge 	endsloop
			

			ldr	w13, [x17, x9, lsl 2]	//w13 = arr[j]
			ldr	w14, [x17, x15, lsl 2]	//w14 = arr[min_index]
			if:
				cmp	w13, w14	//if arr[j] >= arr[min_index], then endif
				bge	endif
				
				mov	x15, x9		//min_index = j
			endif:
			add 	x9, x9, #1
			b	sloop
		endsloop:	
		
		add	x0, x17, x8, lsl #2	//x0 = &arr[i]
		add	x1, x17, x15, lsl #2	//x1 = &arr[min_index]

		bl	swap

		add	x8, x8, #1
		b	sort
	endsort:
	// epilog
	ldp	x29, x30, [sp], #16
	ret


	
	//===================================================================
	// SUM ARRAY FUNCTION
	//===================================================================
	// int sum_array(int arr[], int startidx, int stopidx)
	//		 x0	    x1		  x2
	// Compute the sum of array 'arr' with 'n' values recursively.
	// Input:      arr: address of array
	//        startidx: starting array index
	//         stopidx: ending array index
	// Return: integer sum (int)
	.type	sum_array, @function
sum_array:

	// prolog
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp

	cmp	x1, #0
	bgt	skip
	
	mov 	w4, #0
	mov	w5, #0

	skip:
	cmp	x1, x2
	bge	endsum

	// function body
	ldr	w9, [x0, x1, lsl 2]
	add	w10, w10, w9
	
	add	x1, x1, #1

	//recursive call
	bl	sum_array	

	// function implemented RECURSIVELY!!!!!!!! :)
	
	endsum:
	mov	w0, w10		//return sum
	// epilog
	ldp	x29, x30, [sp], #16
	ret


	
	//===================================================================
	// AVERAGE FUNCTION
	//===================================================================
	// int average(int arr[], int n)
	// Compute the integer average of array 'arr' with 'n' values.
	// Input: arr: address of array
	//          n: size of the array
	// Return: integer average (int)
	.type average, @function
average:
	// prolog
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp

	// function body
	mov	x2, x1	 //move n over to x2
	mov	x1, #0	 //make x1 = 0
	bl 	sum_array
	
	//now x0 is the sum of arr, x2 is still the n values


	udiv	x0, x0, x2	// x0 = sum / n
	
	// epilog
	ldp	x29, x30, [sp], #16
	ret

