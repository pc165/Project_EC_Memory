#pragma once

extern "C" char carac;

extern "C" char gameCards[4][4] = {
{ 'B', 'D', 'E', 'A' },
{ 'C', 'D', 'F', 'B' },
{ 'H', 'G', 'E', 'A' },
{ 'F', 'H', 'G', 'C'} };


extern "C" char cards[16] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'
};

// Matrius 4x4 on guardem les fitxes del joc.       
extern "C" char tauler[4][4] = {
	{ ' ',' ',' ',' ' },
	{ ' ',' ',' ',' ' },
	{ ' ',' ',' ',' ' },
	{ ' ',' ',' ',' ' } };

extern "C" char carac2;			//car�cter llegit de teclat i per a escriure a pantalla.
extern "C" int row;				//fila per a accedir a la matriu gameCards [0..7]
extern "C" char col;			//columna per a accedir a la matriu gameCards [A..H]
extern "C" int indexMat; 		//�ndex per a accedir a la matriu gameCards (index=row*4+col [0..(sizeMatrix-1)].

extern "C" int rowScreen;		//fila on volem posicionar el cursor a la pantalla.
extern "C" int colScreen;		//columna on volem posicionar el cursor a la pantalla.

extern "C" int RowScreenIni;
extern "C" int ColScreenIni;

extern "C" int rowIni;
extern "C" char colIni;

extern "C" int opc;

extern "C" int firstVal;
extern "C" char firstCol;
extern "C" int firstRow;
extern "C" int cardTurn;
extern "C" int totalPairs;
extern "C" int totalTries;
