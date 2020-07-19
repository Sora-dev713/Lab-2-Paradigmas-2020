%hechos necesarios
%saber que es un archivo
%saber que es una lista de archivos
%saber que es commit
/*los espacios*/
agregarElemento([],Elemento).
agregarElemento([X|Xs], Elemento).
eliminarElemento([X|Xs],Elemento).

listaArchivo([]).
listaArchivo([X|Xs]):-string(X

zonas(["nombre", "autor", "fecha", [W,I,L,R]]).
/*Espacios*/
index(["index",[]]).
index(["index",[Achivo]]).
index(["index",[Archivo|Cola]]).
index(I):- I is [N,L], N is "index", (L is [] ; (L is [A], archivo(A));  (L is [A|As], archivo(A), listArch(As))).

workspace(["workspace", []]).
workspace(["workspace", [Archivo]]).
workspace(["workspace",[Archivo|Cola]]).

workspace(W):- W is [N,L], N is "workspace", (L is [] ; (L is [A], archivo(A));  (L is [A|As], archivo(A), listArch(As))).
repositorio(Rep):- Rep is [W, I, L, R], workspace(W), index(I), localRepo(L), remoteRepo(R).

