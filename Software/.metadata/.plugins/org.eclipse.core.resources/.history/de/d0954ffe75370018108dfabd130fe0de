/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

typedef union {
	unsigned int words[4];
	unsigned char bytes[4][4];
} matrix;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}


void addRoundKey(matrix * state, matrix * round_key, int round){

	//idk because errors
	int i, j;

	//print old round key for debug
	/**
	printf("\nOld Key:\n");
	for(i = 0; i < 4; i++){
		for (j = 0; j < 4; j++) {
			printf("%02x, ", round_key->bytes[j][i]);
		}
		printf("\n");
	}
	**/


	//xor state with the round key
	for(i = 0; i < 4; i++){
		state->words[i] ^= round_key->words[i];
	}

	//save the last round key
	matrix temp = *round_key;

	//do the rotation and the substitution in one step
	round_key->bytes[0][0] = aes_sbox[temp.bytes[3][1]];
	round_key->bytes[0][1] = aes_sbox[temp.bytes[3][2]];
	round_key->bytes[0][2] = aes_sbox[temp.bytes[3][3]];
	round_key->bytes[0][3] = aes_sbox[temp.bytes[3][0]];

	//first column special xor
	round_key->words[0] ^= temp.words[0] ^ Rcon[round];

	//next three column xors
	for(i = 1; i < 4; i++){
		round_key->words[i] = temp.words[i] ^ round_key->words[i-1];
	}
}

void subBytes(matrix * state) {
	int i, j;

	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			state->bytes[i][j] = aes_sbox[state->bytes[i][j]];
		}
	}
}

void printthing(matrix *state) {
	int i, j;
	for(i = 0; i < 4; i++){
		for (j = 0; j < 4; j++) {
			printf("%02x, ", state->bytes[j][i]);
		}
		printf("\n");
	}

	printf("\n");
}

void shiftRows(matrix * state) {

	matrix temp = *state;

	state->bytes[0][1] = temp.bytes[1][1];
	state->bytes[1][1] = temp.bytes[2][1];
	state->bytes[2][1] = temp.bytes[3][1];
	state->bytes[3][1] = temp.bytes[0][1];

	state->bytes[0][2] = temp.bytes[2][2];
	state->bytes[1][2] = temp.bytes[3][2];
	state->bytes[2][2] = temp.bytes[0][2];
	state->bytes[3][2] = temp.bytes[1][2];

	state->bytes[0][3] = temp.bytes[3][3];
	state->bytes[1][3] = temp.bytes[0][3];
	state->bytes[2][3] = temp.bytes[1][3];
	state->bytes[3][3] = temp.bytes[2][3];
}

void mixColumns(matrix * state) {

	int i;

	matrix temp = *state;

	for (i = 0; i < 4; i++) {
		state->bytes[i][0] = gf_mul[temp.bytes[i][0]][0] ^ gf_mul[temp.bytes[i][1]][1] ^
				temp.bytes[i][2] ^ temp.bytes[i][3];
		state->bytes[i][1] = temp.bytes[i][0] ^ gf_mul[temp.bytes[i][1]][0] ^
				gf_mul[temp.bytes[i][2]][1] ^ temp.bytes[i][3];
		state->bytes[i][2] = temp.bytes[i][0] ^ temp.bytes[i][1] ^ gf_mul[temp.bytes[i][2]][0] ^
				gf_mul[temp.bytes[i][3]][1];
		state->bytes[i][3] = gf_mul[temp.bytes[i][0]][1] ^ temp.bytes[i][1] ^ temp.bytes[i][2] ^
				gf_mul[temp.bytes[i][3]][0];
	}
}


/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	int i,j;
	matrix round_key;
	matrix state;
	int count = 0;
	for(i = 0; i < 4; i++){
		for(j = 0; j < 4; j++){
			state.bytes[i][j] = charsToHex(msg_ascii[count],msg_ascii[count+1]);
			round_key.bytes[i][j] = charsToHex(key_ascii[count],key_ascii[count+1]);
			count+=2;
		}
		key[i] = 0;
		key[i] |= round_key.bytes[i][0];
		key[i] = key[i] << 8;
		key[i] |= round_key.bytes[i][1];
		key[i] = key[i] << 8;
		key[i] |= round_key.bytes[i][2];
		key[i] = key[i] << 8;
		key[i] |= round_key.bytes[i][3];
	}



	//hardcodes the key
	/**
	round_key.words[0] = 0x03020100;
	round_key.words[1] = 0x07060504;
	round_key.words[2] = 0x0b0a0908;
	round_key.words[3] = 0x0f0e0d0c;

	state.words[0] = 0xdc98e2ec;
	state.words[1] = 0xdc98e2ec;
	state.words[2] = 0xdc98e2ec;
	state.words[3] = 0xdc98e2ec;
	**/


	addRoundKey(&state,&round_key,1);

	for (i = 0; i < 9; i++) {
		subBytes(&state);
		//printf("After subBytes:\n");
		//printthing(&state);
		shiftRows(&state);
		//printf("After shiftRows:\n");
		//printthing(&state);
		mixColumns(&state);
		//printf("After mixColumns:\n");
		//printthing(&state);
		addRoundKey(&state,&round_key, i+2);
		//printf("After addKey:\n");
		//printthing(&state);
		//printf("\n");
	}

	subBytes(&state);
	shiftRows(&state);
	addRoundKey(&state,&round_key, 11);

	for (i = 0; i < 4; i++) {
		msg_enc[i] = 0;
		msg_enc[i] |= state.bytes[i][0] << 24;
		msg_enc[i] |= state.bytes[i][1] << 16;
		msg_enc[i] |= state.bytes[i][2] << 8;
		msg_enc[i] |= state.bytes[i][3];
	}

	AES_PTR[0] = key[0];
	AES_PTR[1] = key[1];
	AES_PTR[2] = key[2];
	AES_PTR[3] = key[3];

}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];


	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
