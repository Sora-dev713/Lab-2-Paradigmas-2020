%hechos necesarios
%saber que es un archivo
%saber que es una lista de archivos
%saber que es commit
/*los espacios*/
/*
agregarElemento([],Elemento).
agregarElemento([X|Xs], Elemento).
eliminarElemento([X|Xs],Elemento).

listaArchivo([]).
listaArchivo([X|Xs]):-string(X)


zonas(["Nombre", "Autor", "Fecha", [W,I,L,R]]).*/
/*Espacios
index(["index",[]]).
index(["index",[Achivo]]).
index(["index",[Archivo|Cola]]).
index(I):- I is [N,L], N is "index", (L is [] ; (L is [A], archivo(A));  (L is [A|As], archivo(A), listArch(As))).

workspace(["workspace", []]).
workspace(["workspace", [Archivo]]).
workspace(["workspace",[Archivo|Cola]]).

workspace(W):- W is [N,L], N is "workspace", (L is [] ; (L is [A], archivo(A));  (L is [A|As], archivo(A), listArch(As))).
repositorio(Rep):- Rep is [W, I, L, R], workspace(W), index(I), localRepo(L), remoteRepo(R).
*/
%------------------------------------------------------------------------------------
%       TODO LO DE ARRIBA ES UN BORRADOR
%------------------------------------------------------------------------------------



%trabajando de manmera lineal
/*primero necesito el TDA Git, el cual será representado por
[Nombre del Repo,, Autor Fecha/Hora, [Zonas]]

Zonas esta representado por:
[ ["Workspace", [_]] , ["Index",[_]] , ["Loc_Repo", [_]] , ["Rem_Repo", [_]] ]
los espacios en anonimo es porque pueden ir tanto vacios como con archivos de antes, sobre todo en el caso de Workspace e index

para eso necesitaremos la base de datos de cada zona */

workspace(["Workspace", []]).
index(["Index", []]).
localRepo(["Loc_Repo", []]).
remoteRepo(["Rem_Repo",[]]).

/*luego necesitamos el creador del TDA Git, el cual es la funcion GitInit
*/
gitInit(NombreRepo, Autor, RepoOutput):- workspace(W), index(I), localRepo(L), remoteRepo(R), RepoOutput = [NombreRepo, Autor, "Fecha", [W, I, L, R]].

/*Teniendo esto, vamos a necesitar una funcion que nos pueda ingresar los archivos al workspace, para eso necesitaremos las siguientes funciones
agregarCabeza
agregarAWork-> devuelve un repo de git con solo el workspace editado
parteYa()<- para verificar si es que esta en la lista ya 
esto es para poder agregar manualmente los archivos del workspace al git, para los ejemplos daremos workspaces ya llenos tambien
*/
parteYa(X,[X,_]).
parteYa(X,[_,Xs]):- parteYa(X,Xs).

agregarCabeza(X,[],[X]).
agregarCabeza(X,[Y|Ys], [X, Y|Ys]).

agregarAWork(Z, [], Z).
agregarAWork([N,A,F,[[Nombre,Cont],I,L,R]], [X|Xs], Out):- ((parteYa(X, Cont)), agregarAWork([N,A,F,[[Nombre,Cont],I,L,R]], Xs, Out));
                                                           (agregarCabeza(X, Cont, Aux),agregarAWork([N,A,F,[[Nombre,Aux],I,L,R]], Xs, Out)).
