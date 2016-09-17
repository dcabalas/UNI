/* ---------------------------------PROLOG----------------------------------- */

//Calcula posiciones fuera de amenaza (agujeros no evaluados aquí).
link([], Cs, Cs).
link([A|As],Bs,[A|Cs]):- link(As, Bs, Cs).
itBoard(Y,Y,LQ,LB,R):- itCol(Y,Y,LQ,LB,R,Y).
itBoard(X,Y,LQ,LB,K):-
	X1 = X+1 & link(MF,R,K) & itCol(X,Y,LQ,LB,MF,Y) & itBoard(X1,Y,LQ,LB,R).
itCol(X,0,LQ,LB,[],S):-	hitQ([X,0],LQ,LB,S).
itCol(X,0,_,_,[[X,0]],_).
itCol(X,Y,LQ,LB,MF,S):-
	Y1 = Y-1 & hitQ([X,Y],LQ,LB,S) & itCol(X,Y1,LQ,LB,MF,S).
itCol(X,Y,LQ,LB,[[X,Y]|MF],S):- Y1 = Y-1 & itCol(X,Y1,LQ,LB,MF,S).
hitQ([],[],_,_).
hitQ([X,Z],[[X,Y]|R],LB,S):-
	gt(Z,Y,R1) & lt(Z,Y,R2) & not(vertical(X,R2,R1,LB)).
hitQ([Z,Y],[[X,Y]|R],LB,S):-
	gt(Z,X,R1) & lt(Z,X,R2) & not(horizontal(Y,R2,R1,LB)).
hitQ([Z,Y],[[A,B]|R],LB,S):- Z-A == Y-B & not(diagDsc([Z,Y],[A,B],LB)).
hitQ([Z,Y],[[A,B]|R],LB,S):- Z-A == -(Y-B) & not(diagAsc([Z,Y],[A,B],LB)).
hitQ(Q,[Car|Cdr],LB,P):- hitQ(Q,Cdr,LB,P).
diagDsc([Z,Y],[A,B],[[BX,BY]|R]):-
	Z-BX == Y-BY & lt(Z,A,R1) & gt(Z,A,R2) & middle(BX,R1,R2).
diagDsc([Z,Y],[A,B],[[_,_]|R]):- diagDsc([Z,Y],[A,B],R).
diagAsc([Z,Y],[A,B],[[BX,BY]|R]):-
	Z-BX == -(Y-BY) & lt(Z,A,R1) & gt(Z,A,R2) & middle(BX,R1,R2).
diagAsc([Z,Y],[A,B],[[_,_]|R]):- diagAsc([Z,Y],[A,B],R).
vertical(X,R1,R2,[[X,K]|_]):- less(K,R2) & great(K,R1).
vertical(X,R1,R2,[[_,_]|R]):- vertical(X,R1,R2,R).
horizontal(X,R1,R2,[[K,X]|_]):- less(K,R2) & great(K,R1).
horizontal(X,R1,R2,[[_,_]|R]):- horizontal(X,R1,R2,R).
middle(X,Y,Z):- X>Y & X<Z.
less(X,Y):-Y>X.
great(X,Y):-X>Y.
gt(X,Y,X):-X>Y.
gt(X,Y,Y):-Y>=X.
lt(X,Y,X):-X<Y.
lt(X,Y,Y):-Y<=X.

//Genera el tablero en base al tamaño dado.
bb(Size,Size,Size,[[Size,Size]]).
bb(It,It,Size,[[It,It]|L]):- N_val = It+1 & bb(N_val,It,Size,L).
bb(Size,It,Size,[[Size,It]|L]):- N_it = It+1 & bb(0,N_it,Size,L).
bb(Val,It,Size,[[Val,It]|L]):- N_val = Val+1 & bb(N_val,It,Size,L).

//Dada una lista extrae su primera posición
//si no contiene elementos devuelve vacío.
first([],nil,nil).
first([[A,B]|_],A,B).

/* ---------------------------------PROLOG----------------------------------- */

/* ---------------------------------INICIO----------------------------------- */

!start.
+!start : playAs(1) <- !bb.							// Calcula tablero.
+!start : not playAs(_) <- !bb. 					// Calcula tablero.
+!start : playAs(0) <- !bb; +player(0); -player(0).	// Calcula tablero y juega.

//Establece el máximo de fichas para cada rol.
+size(S) : playAs(0) <- .print("Limite W impuestos: ",S/2); +numQW(S/2).
+size(S) : playAs(1) <- .print("Limite B impuesto: ",S/2); +numQB(S/2).
+size(S) : not playAs(_) <- .print("Limite C impuesto: ",S/4); +numBH(S/4).

//Actualiza contador blancas.
+!updateQW : numQW(N) <- -numQW(_); +numQW(N-1).
//Actualiza contador negras.
+!updateQB : numQB(N) <- -numQB(_); +numQB(N-1).
//Actualiza contador bloques y agujeros.
+!updateBH : numBH(N) <- -numBH(_); +numBH(N-1).

/* ---------------------------------INICIO----------------------------------- */

/* --------------------------------COMUNES----------------------------------- */

// Calcula el entorno.
+!env : size(S) & bad(N)
	<-
		.findall([X,Y],queen(X,Y),Q);		// Busca todas las reinas.
		.findall([X,Y],block(X,Y),B);		// Busca todos los bloques.
		.findall([X,Y],hole(X,Y),H);		// Busca todos los agujeros.
		-env(_,_,_,_,_);					// Borra el estado anterior.
		+env(S-1,Q,B,H,N).					// Agrega el nuevo estado.

// Calcula el tablero.
+!bb : size(ES) & S=ES-1
	<-
		+bad([[0,0],[S,S],[0,S],[S,0]]);	// Un bloque aquí sería inutil.
		?bb(0,0,S,BB);						// Calcula el tablero de SxS.
		+board(BB).							// Añade el tablero a la BC.

//Calcula las posiciones no ocupadas del tablero actual...
+!notBussy(L) : board(BB) & env(S,Q,B,H,N)
	<- .concat(Q,B,H,N,OC); .difference(BB,OC,L).
//...O de un tablero con supuestos de reinas y/o bloques.
+!notBussy(Bn,Qn,L) : board(BB) & env(S,_,_,H,N)
	<- .concat(Qn,Bn,H,N,OC); .difference(BB,OC,L).

//Calcula las posiciones libres en base al estado actual del tablero...
+!free(L,X,Y) : env(S,Q,B,H,_)
	<- ?itBoard(0,S,Q,B,F1); .difference(F1,H,L); !random(L,X,Y).
//...O en base al estado con supuestos de reinas y/o bloques y/o agujeros.
+!free(Hn,Bn,Qn,L,X,Y) : env(S,_,_,_,_)
	<- ?itBoard(0,S,Qn,Bn,F1); .difference(F1,Hn,L); !random(L,X,Y).

/* --------------------------------COMUNES----------------------------------- */

/* ---------------------------------BC.AG------------------------------------ */

// Si es jugador... Actualiza el entorno y juega.
+player(P) : playAs(P) <- !env; !ag.

//Si se añade un bloque actualiza el contador de bloques y agujeros.
+block(_,_) : playAs(_) & numBH(N) <- -numBH(_); +numBH(N-1).
//Si se añade un agujero actualiza el contador de bloques y agujeros.
+hole(_,_) : playAs(_) & numBH(N) <- -numBH(_); +numBH(N-1).

// En caso de ser rechazado: borra todos los percepts sensibles.
+decline[source(configurer)]
	<- -plan(_,_); -save(_,_); -msg; -decline[source(_)].
// En caso de ser aceptado.
+accept[source(configurer)] : plan(X,Y)
	<- +save(X,Y); -plan(_,_); -msg; -accept[source(_)].

/* ---------------------------------BC.AG------------------------------------ */

/* -------------------------------LOGICA.AG---------------------------------- */

//Si blancas llega al máximo...
+!ag : numQW(N) & N<=0 <- .print("Admito la derrota :(").
//Si negras llega al máximo... (Nunca va entrar aquí salvo que empiezen negras).
+!ag : numQB(N) & N<=0 <- .print("Admito la derrota :(").

//Si hay bandera, no solicita bloque ni planea reina.
+!ag : msg | (numBH(N) & N<=0) 
	<- 
		!q1(X1,Y1); 
		.print("Q1: [",X1,",",Y1,"], B: [nil,nil], Q2: [nil,nil]");
		!go(X1,Y1,nil,nil,nil,nil).

//Si no hay bandera, solicita bloque y planea reina.
+!ag : env(_,Q,B,H,_)
	<-
	//Reina turno actual
		!q1(X1,Y1);					// Calcula posición para la reina.
	//Bloque a solicitar
		.concat(Q,[[X1,Y1]],Qn);	// (Suponiendo la reina colocada)...
		!notBussy(B,Qn,N1);			// Lista no ocupadas.
		!random(N1,X2,Y2);			// El par(X2,Y2) será el bloque a solicitar.
	//Reina turno siguiente
		.concat(B,[[X2,Y2]],Bn);	// (Suponiendo reina y bloque colocados)...
		!free(H,Bn,Qn,F2,_,_); 		// Lista libres.
		!adj(A,X2,Y2);				// Lista de adyacentes.
		.intersection(A,F2,AF);		// Lista de adyacentes no amenazadas.
		?first(AF,X3,Y3);			// El par(X3,Y3) planea ser la prox reina.
	//Printa la jugada.
		.print("Q1: [",X1,",",Y1,"], B: [",X2,",",Y2,"], Q2: [",X3,",",Y3,"]");
	//Comprueba, actua...
		!go(X1,Y1,X2,Y2,X3,Y3).		// Gestion banderas y planes también.

//Sin reina posible.
+!go(nil,nil,_,_,_,_) <- .print("Admito la derrota :(").
//Si sólo la reina actual es válida. Actualiza blancas.
+!go(X1,Y1,nil,nil,nil,nil) : player(0) <- !updateQW; queen(X1,Y1).
//Si sólo la reina actual es válida. Actualiza negras.
+!go(X1,Y1,nil,nil,nil,nil) : player(1) <- !updateQB; queen(X1,Y1).
//Todos los valores correctos. Actualiza blancas.
+!go(X1,Y1,X2,Y2,X3,Y3) : player(0)
	<- !msg(X2,Y2); +plan(X3,Y3); !updateQW; queen(X1,Y1).
//Todos los valores correctos. Actualiza negras.
+!go(X1,Y1,X2,Y2,X3,Y3) : player(1)
	<- !msg(X2,Y2); +plan(X3,Y3); !updateQB; queen(X1,Y1).

//Si no hay ninguna reina guardada...
+!q1(X,Y) : not save(_,_) <- !free(_,X,Y).
//Calcula la reina si la guardada no es válida.
+!q1(X,Y) : save(nil,nil) <-  -save(_,_); !free(_,X,Y).
//Si no, evalua la guardada...
+!q1(X,Y) : save(X1,Y1)
	<-  -save(_,_); !free(L,X2,Y2);
	if(.member([X1,Y1],L)) { X=X1; Y=Y1 } else { X=X2; Y=Y2}. //Pos segura.

//Comunica al config lo que queremos hacer y levanta bandera de comunicación.
+!msg(X,Y) <- .send(configurer,tell,block(X,Y)); +msg.

//Obtiene una posición aleatoria de una lista dada.
+!random(L,X,Y) <- .shuffle(L,LS); ?first(LS,X,Y).

//Obtiene la posiciones adyacentes.
//Que salgan de rango se controla luego con la intersección.
+!adj(L,X,Y) : env(S,_,_,_,_) & I=X+1 & J=Y+1 & N=X-1 & M=Y-1
	<- L=[[N,Y],[N,J],[N,M],[I,J],[I,Y],[I,M],[X,J],[X,M]].

/* -------------------------------LOGICA.AG---------------------------------- */

/* --------------------------------BC.CFG------------------------------------ */

+queen(_,_) : not playAs(_)					// Si no es jugador y es turno B.
	<-
		.count(queen(_,_),Nq);
		if((Nq mod 2)==1){ !env; !conf; }.	// Actualiza entorno y juega.

+block(X,Y)[source(Ag)] : not Ag=percept & not playAs(_)
	<-
		if(.number(X) & .number(Y))		// Si las coordenadas son válidas.
		{
			!env;										// Actualiza entorno.
			!calc(block,X,Y,Val);						// Libres generadas.
			-block(X,Y)[source(Ag)];					// Borra este percept.
			if(Ag=black) { +planB(block,X,Y,Val); };	// Guarda plan negras.
			if(Ag=white) { +planW(block,X,Y,Val); };	// Guarda plan blancas.
		}.

+hole(X,Y)[source(Ag)] : not Ag=percept & not playAs(_)
	<-
		if(.number(X) & .number(Y))		// Si las coordenadas son válidas.
		{
			!env;										// Actualiza entorno.
			!calc(hole,X,Y,Val);						// Libres generadas.
			-hole(X,Y)[source(Ag)];						// Borra este percept.
			if(Ag=black) { +planB(hole,X,Y,Val); };		// Guarda plan negras.
			if(Ag=white) { +planW(hole,X,Y,Val); };		// Guarda plan blancas.
		}.

/* --------------------------------BC.CFG------------------------------------ */

/* ------------------------------LOGICA.CFG---------------------------------- */

//Si configurador llega al máximo de figuras.
+!conf : numBH(N) & N<=0 <- .print("CFG, no puedo poner más figuras...").

//Si todo está en orden el configurador juega entre blancas y negras.
+!conf : true
	<-
		!compare;								// Evalua ambas estrategias.
		?task(T,X,Y);							// Lee la estrategia ganadora.
		if(queen(X,Y)|block(X,Y)|hole(X,Y))		// Comprueba que no pise figura.
			{
				.print("Recalculando...");		// Notifica si eso pasa.
				!remove;						// Borra todos los percepts.
				!noWin;							// Genera su estrategia.
				!put;							// Coloca el bloque.
				!updateBH;						// Actualizo el contador.
			}
		else									// Si no machaca figura alguna.
		{
			!put(T,X,Y);						// Coloca en la pos dada.
			!updateBH;							// Actualiza contador.
		};
		!notify;								// Notifica estado a los ag's.
		!remove.								// Borra percepts sensibles.

//Cuando los demás fallan genero mi propia estrategia.
+!planC : true
	<-
		!env;									// Actualizo entorno.
		!notBussy(L);							// Casillas sin figura.
		!random(L,X,Y);							// Par aleatorio sin figura.
		+task(block,X,Y).						// Genero tarea.

//En caso especial.
+!put : task(_,X,Y) <- block(X,Y).
//Si el tipo de figura solicitada es un bloque.
+!put(block,X,Y) <- block(X,Y).
//Si el tipo de figura solicitada es un agujero.
+!put(hole,X,Y) <- hole(X,Y).

//Borra los autopercepts generados.
+!remove : true <- -win(_); -task(_,_,_); -planB(_,_,_,_); -planW(_,_,_,_).

//Calcula el número de posiciones libres suponiendo un bloque.
+!calc(block,X,Y,Len) : env(_,Q,B,H,_)
	<- .concat(B,[[X,Y]],Bn); !free(H,Bn,Q,F1,_,_); .length(F1,Len).
//Calcula el número de posiciones libres suponiendo un agujero.
+!calc(hole,X,Y,Len) : env(_,Q,B,H,_)
	<- .concat(H,[[X,Y]],Hn); !free(Hn,B,Q,F1,_,_); .length(F1,Len).

//Compara el número de casillas que genera cada estrategia.
//Ambas iguales, decide el configurador.
+!compare : planB(Tb,Xb,Yb,V) & planW(Tw,Xw,Yw,V) <-  !noWin.
//Ningua estrategia, decide el configurador.
+!compare : not planB(_,_,_,_) & not planW(_,_,_,_) <- !noWin.
//Sólo estrategia de blancas, gana blancas.
+!compare : not planB(_,_,_,_) & planW(Tw,Xw,Yw,VW) <- !winW(Tw,Xw,Yw).
//Sólo estrategia de negras, gana negras.
+!compare : planB(Tb,Xb,Yb,VB) & not planW(_,_,_,_) <- !winB(Tb,Xb,Yb).
//Ambas estrategias pero blancas genera más libres, gana blancas.
+!compare : planB(Tb,Xb,Yb,VB) & planW(Tw,Xw,Yw,VW) & VW>VB <- !winW(Tw,Xw,Yw).
//Ambas estrategias pero negras genera más libres, gana negras.
+!compare : planB(Tb,Xb,Yb,VB) & planW(Tw,Xw,Yw,VW) & VB>VW <- !winB(Tb,Xb,Yb).

//Si no hay ganador calcula aleatoriamente una posición para el bloque.
+!noWin : true  <- .print("Decido yo..."); !planC; +win(c).
//Si gana blancas guarda lo solicitado por blancas como tarea.
+!winW(T,X,Y) <- .print("Gana blancas... [",X,",",Y,"]"); +task(T,X,Y); +win(w).
//Si gana negras guarda lo solicitado por negras como tarea.
+!winB(T,X,Y) <- .print("Gana negras... [",X,",",Y,"]"); +task(T,X,Y); +win(b).

//Si no hay ganador notifica el rechazo a ambos.
+!notify : win(c) <- .send(white,tell,decline); .send(black,tell,decline).
//Si gana blancas notifica a blancas aceptación y a negras rechazo.
+!notify : win(w) <- .send(white,tell,accept); .send(black,tell,decline).
//Si gana negras notifica a negras aceptación y a blancas rechazo.
+!notify : win(b) <- .send(white,tell,decline); .send(black,tell,accept).

/* ------------------------------LOGICA.CFG---------------------------------- */
