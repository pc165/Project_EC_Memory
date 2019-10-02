#include "globals.h"
#include <iostream>
#include <stdio.h>
#include <conio.h>
#include <iomanip>
#include<stdlib.h>
#include<time.h>
#include<windows.h>

extern "C" {
	// Subrutines en ASM

	void posCurScreenP1();
	void moveCursorP1();
	void openP1();
	void getMoveP1();
	void movContinuoP1();
	void openContinuousP1();
	void setupBoard();


	void printChar_C(char c);
	int clearscreen_C();
	int printMenu_C();
	int gotoxy_C(int row_num, int col_num);
	char getch_C();
	int printBoard_C(int tries);
	void continue_C();
}

#define DimMatrix 4

int row = 0;			//fila de la pantalla
char col = 'A';   		//columna actual de la pantalla
int rowIni;
char colIni;

char carac, carac2;

int opc;
int indexMat;
int rowScreen;
int colScreen;
int RowScreenIni;
int ColScreenIni;

int firstVal, firstRow, cardTurn;
char firstCol;
int totalPairs;
int totalTries;

//Mostrar un car�cter
//Quan cridem aquesta funci� des d'assemblador el par�metre s'ha de passar a traves de la pila.
void printChar_C(char c) {
	putchar(c);
}

//Esborrar la pantalla
int clearscreen_C() {
	system("CLS");
	return 0;
}

int migotoxy(int x, int y) { //USHORT x,USHORT y) {
	COORD cp = { y,x };
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cp);
	return 0;
}

//Situar el cursor en una fila i columna de la pantalla
//Quan cridem aquesta funci� des d'assemblador els par�metres (row_num) i (col_num) s'ha de passar a trav�s de la pila
int gotoxy_C(int row_num, int col_num) {
	migotoxy(row_num, col_num);
	return 0;
}

//Funci� que inicialitza les variables m�s importants del joc
void init_game() {
	for (int i = 0; i < 4; i++) {           //Inicialitza totes les posicions de la matriu tauler a 0 (totes les caselles tapades)   
		for (int j = 0; j < 4; j++) {
			tauler[i][j] = ' ';
		}
	}
}

//Imprimir el men� del joc
int printMenu_C() {

	clearscreen_C();
	gotoxy_C(1, 1);
	printf("______________________________________________________________________________\n");
	printf("|                                                                             |\n");
	printf("|                              MENU MEMORY                                    |\n");
	printf("|_____________________________________________________________________________|\n");
	printf("|                                                                             |\n");
	printf("|                                                                             |\n");
	printf("|                                                                             |\n");
	printf("|                               1. Show cursor                                |\n");
	printf("|                               2. Move                                       |\n");
	printf("|                               3. Move continous                             |\n");
	printf("|                               4. Open                                       |\n");
	printf("|                               5. Open continous                             |\n");
	printf("|                                                                             |\n");
	printf("|                               0. Exit                                       |\n");
	printf("|                                                                             |\n");
	printf("|_____________________________________________________________________________|\n");
	printf("|                                                                             |\n");
	printf("|                               OPTION:                                       |\n");
	printf("|_____________________________________________________________________________|\n");
	return 0;
}

//Llegir una tecla sense espera i sense mostrar-la per pantalla
char getch_C() {
	DWORD mode, old_mode, cc;
	HANDLE h = GetStdHandle(STD_INPUT_HANDLE);
	if (h == NULL) {
		return 0; // console not found
	}
	GetConsoleMode(h, &old_mode);
	mode = old_mode;
	SetConsoleMode(h, mode & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT));
	char c = 0;
	ReadConsole(h, &c, 1, &cc, NULL);
	SetConsoleMode(h, old_mode);

	return c;
}


/**
* Mostrar el tauler de joc a la pantalla. Les l�nies del tauler.
*
* Aquesta funci� es crida des de C i des d'assemblador,
* i no hi ha definida una subrutina d'assemblador equivalent.
* No hi ha pas de par�metres.
*/
void printBoard_C() {

	int i, j, r = 1, c = 25;

	clearscreen_C();
	gotoxy_C(r++, 20);
	printf("===============================");
	gotoxy_C(r++, c);			//T�tol
	printf("       MEMORY             ");
	gotoxy_C(r++, c);
	printf(" pairs: %d    tries: %d", totalPairs, totalTries);
	gotoxy_C(r++, 20);
	printf("===============================");
	gotoxy_C(r++, c);			//Coordenades
	printf("    A   B   C   D    ");
	for (i = 0; i < DimMatrix; i++) {
		gotoxy_C(r++, c);
		printf("  +");			// "+" cantonada inicial
		for (j = 0; j < DimMatrix; j++) {
			printf("---+");		//segment horitzontal	
		}
		gotoxy_C(r++, c);
		printf("%i |", i + 1);	//Coordenades
		for (j = 0; j < DimMatrix; j++) {
			printf(" %c |", tauler[i][j]);		//l�nies verticals
		}
	}
	gotoxy_C(r++, c);
	printf("  +");
	for (j = 0; j < DimMatrix; j++) {
		printf("---+");
	}
}


int main(void)
{
	int i, j;
	opc = 1;
	srand(time(NULL));

	RowScreenIni = 7;
	ColScreenIni = 29;

	while (opc != '0') {
		totalPairs = 8;
		totalTries = 8;

		init_game();                    //Inicialitzar variables importants del joc
		setupBoard();

		printMenu_C();					//Mostrar men�
		gotoxy_C(18, 40);				//Situar el cursor
		opc = getch_C();				//Llegir una opci�
		switch (opc) {
		case '1':						//SHOW CURSOR:
			printBoard_C();				//Mostrar el tauler

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);		//Situar el cursor a sota del tauler
			printf("Press any key ");

			row = 2;
			col = 'C';
			posCurScreenP1();			//Posicionar el cursor a pantalla.
			getch_C();					//Esperar que es premi una tecla

			break;

		case '2':                //MOVE:
			clearscreen_C();  	 //Esborra la pantalla
			printBoard_C();   	 //Mostrar el tauler.

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("Press i,j,k,l ");

			row = 2;
			col = 'C';
			posCurScreenP1();	//Posicionar el cursor a pantalla.

			getMoveP1();		//llegir una tecla de moviment
			moveCursorP1();		//Moure la posici� del cursor a la matriu

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("Press any key ");

			row = 2;
			col = 'C';
			posCurScreenP1();	//Posicionar el cursor a pantalla.


			getch_C();
			break;

		case '3': 				//MOVE CONTINUOUS:
			clearscreen_C();  	//Esborra la pantalla
			printBoard_C();   	//Mostrar el tauler.

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("Press i,j,k,l");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 1);
			printf("Press s to Exit");

			row = 2;
			col = 'C';
			posCurScreenP1();	//Posicionar el cursor a pantalla.

			carac2 = 0;
			movContinuoP1();  	//Moure el cursor cont�nuament per la pantalla

			break;
		case '4': 				//OPEN:  
			clearscreen_C();  	//Esborra la pantalla
			printBoard_C();   	//Mostrar el tauler.

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("Press i,j,k,l");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 4);
			printf("Press Espace to open");

			row = 2;
			col = 'C';
			posCurScreenP1();	//Posicionar el cursor a pantalla.

			carac2 = 0;
			movContinuoP1();	//Moure el cursor cont�nuament per la pantalla
			openP1();			//Obrir una casella 

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("                       ");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 3);
			printf("                       ");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni);
			printf("Press any key ");
			getch_C();
			break;

		case '5': 				//OPEN CONTINUOUS:

			setupBoard();
			totalPairs = 8;
			totalTries = 8;

			clearscreen_C();  	//Esborra la pantalla
			printBoard_C();   	//Mostrar el tauler.

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("Press i,j,k,l");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 9);
			printf("Press Espace to open or s to exit");

			row = 2;
			col = 'C';
			posCurScreenP1();    //Posicionar el cursor a pantalla.

			carac2 = 0;
			openContinuousP1();  //Obrir cont�nuament les caselles del tauler

			gotoxy_C(RowScreenIni + (DimMatrix * 2), ColScreenIni);
			printf("                       ");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni - 9);
			printf("                                   ");
			gotoxy_C(RowScreenIni + (DimMatrix * 2) + 1, ColScreenIni);
			printf("Press any key ");
			getch_C();
			break;
		}
	}

	gotoxy_C(19, 1);	//Situar el cursor a la fila 19
	return 0;


}

// Ejecutar programa: Ctrl + F5 o men� Depurar > Iniciar sin depurar
// Depurar programa: F5 o men� Depurar > Iniciar depuraci�n

// Sugerencias para primeros pasos: 1. Use la ventana del Explorador de soluciones para agregar y administrar archivos
//   2. Use la ventana de Team Explorer para conectar con el control de c�digo fuente
//   3. Use la ventana de salida para ver la salida de compilaci�n y otros mensajes
//   4. Use la ventana Lista de errores para ver los errores
//   5. Vaya a Proyecto > Agregar nuevo elemento para crear nuevos archivos de c�digo, o a Proyecto > Agregar elemento existente para agregar archivos de c�digo existentes al proyecto
//   6. En el futuro, para volver a abrir este proyecto, vaya a Archivo > Abrir > Proyecto y seleccione el archivo .sln
