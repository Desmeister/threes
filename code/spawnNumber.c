//Spawns a 1 or a 2 in a random, empty location
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void spawnNumber(int *board, int move){
    int countEmpty;
	int countOnes;
	int countTwos;
    int randomSquare;
    int randomNumber;
    int square;
    int i;

    //Initialize the random number generator
    srand(time(NULL));

    //Count the number of empty spaces
    countEmpty = 0;
    for(i=0;i<16;i++){
        if(board[i]==0)
            countEmpty++;
		if(board[i]==1)
			countOnes++;
		if(board[i]==2)
			countTwos++;
	}

    //Get a random empty space and number
    randomSquare = rand()%countEmpty+1; //From 1st to "CountEmpty"th empty
	if(countOnes>countTwos)
		randomNumber = 2;
	else
		randomNumber = 1;

    //Go to that square, and change it
    square=0;
    while(randomSquare>0){
        if(board[square]==0)
            randomSquare--;
        if(randomSquare==0)
            break;
        square++;
    }

    board[square] = randomNumber;

}

