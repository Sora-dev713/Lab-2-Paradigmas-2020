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
localRepo(["Local Repository", []]).
remoteRepo(["Remote Repository",[]]).

/*luego necesitamos el creador del TDA Git, el cual es la funcion GitInit
*/
gitInit(NombreRepo, Autor, RepoOutput):- get_time(Time), convert_time(Time, Date), workspace(W), index(I), localRepo(L), remoteRepo(R), RepoOutput = [NombreRepo, Autor, Date, [W, I, L, R]].

/*Teniendo esto, vamos a necesitar una funcion que nos pueda ingresar los archivos al workspace, para eso necesitaremos las siguientes funciones
agregarCabeza->añade elementos a la cabeza de una lista
agregarAWork-> devuelve un repo de git con solo el workspace editado
parteYa()<- para verificar si es que esta en la lista ya 
esto es para poder agregar manualmente los archivos del workspace al git, para los ejemplos daremos workspaces ya llenos tambien
*/
parteYa(X,[X|_]).
parteYa(X,[_|Xs]):- parteYa(X,Xs).

agregarCabeza(X,[],[X]).
agregarCabeza(X,[Y|Ys], [X, Y|Ys]).

/*que hace agregar a work:
toma una lista de archivos dada por el usuario y los integra en el Workspace, siendo este dado por el repositoirio git completo
*/
agregarAWork(Z, [], Z).
agregarAWork([N,A,F,[[Nombre,Cont],I,L,R]], [X|Xs], Out):- ((parteYa(X, Cont)), agregarAWork([N,A,F,[[Nombre,Cont],I,L,R]], Xs, Out));
                                                           (agregarCabeza(X, Cont, Aux),agregarAWork([N,A,F,[[Nombre,Aux],I,L,R]], Xs, Out)).

/*
Teniendo ya archivos en el workspace, podemos hacer que estos sean agregados en el Index, para eso necesitaremos las siguientes funciones
agregarCabeza-> ya explicada anteriormente
parteYa-> Explicada anteriormente
EliminarElemento-> Elimina el elemento que se ha encontrado en la lista
gitAdd->la funcion necesaria
lo que gitAdd debe de hacer es pasar los archivos entregados a el index, pero debemos antes saber si estos estan o no en el workspace,
lo que haremos es extraer ambas listas de archivos (Workspace e Index), y moveremos los que ya sean parte del workspace, ahora, para evitar 
duplicados, tambien veremos si el archivo ya esta en el Index, por lo que la llamaremos 2 veces*/
delete([], _, Auxiliar, Auxiliar).
delete([X], X, Auxiliar, Auxiliar).
delete([X| Xs], X, Aux, Out):- append(Aux, Xs , Aux2), delete([], _, Aux2, Out).
delete([X| Xs], A, Aux, Out):- append(Aux, [X], Aux2), delete(Xs, A, Aux2, Out).


gitAdd(Z, [], Z).
gitAdd([N,A,F,[[NW,Work],[NI,Ind],L,R]], [X|Xs] , RepoOutput):- (parteYa(X, Work), not(parteYa(X, Ind)), agregarCabeza(X, Ind, AuxI), delete(Work, X, [], AuxW), gitAdd([N,A,F,[[NW,AuxW],[NI,AuxI],L,R]], Xs , RepoOutput));
                                                         (not(parteYa(X, Work)), gitAdd([N,A,F,[[NW,Work],[NI,Ind],L,R]], Xs , RepoOutput));
                                                         (parteYa(X, Work), parteYa(X, Ind), delete(Work, X, [], AuxW), gitAdd([N,A,F,[[NW,AuxW],[NI,Ind],L,R]], Xs , RepoOutput)).

/* luego de esto, tenemos que pasar con el gitCommit, lo que hace esto es que toma todos los archivos del index, 
los pasa a una lista,  y con un mensaje que agregue el ususario, se crea un commit (TDA) que tiene la forma de:

Commit = [[Lista de archivos], "Mensaje"].

para esto podemos usar un predicado bastante simple:

crearCommit(Lista archivos, Mensaje, Salida).*/
crearCommit(Lista, Mensaje, [Lista, Mensaje]).
/*y como en este caso, se mueven los archivos, la lista de archivos del index deberia quedar vacía.*/
/*teniendo esto listo, podemos proceder a hacer el gitCommit, lo cual hara uso de crearCommit para agregar un commit al LocalRepo.*/

gitCommit([N,A,F,[W,[NI,Ind],[NL,LCommits],R]], Mensaje, RepoOutput):- not(Ind = []), crearCommit(Ind, Mensaje,Commit), append([Commit], LCommits, AuxL), RepoOutput= [N,A,F,[W,[NI,[]],[NL,AuxL],R]]. 

/* Luego que tenemos el commit , debemos hacer el gitPush, el cual consiste en copiar los contenidos del Repositorio Local en el 
Repositorio Remoto. Esto será creado de forma tal que iremos revisando si el commit existe en la lista y lo pondremos en una lista auxiliar si es que no,
puesto que se deben copiar y no mover.
luego de eso, tomando en cuenta que estaran ordenados de mas nuevo a mas antiguo, agregaremos esa lista a la cabeza de la lista de commits del 
Repositorio Remoto.

para esto tendremos lo siguiente:
agregarCabeza: Explicado anteriormente.
filtrarLista: Lo que hara esto es entregar una lista con commits que esten en la Lista A pero no esten en la Lista B.
             parteYa: para verificar.
gitPush: le pasaremos el Repo inicial con el/los commmit(s) en el Local Repository, y nos saldrá uno con los commits copiados en el Remote Repository.*/

filtrarLista([], _, Aux, Aux).
filtrarLista([X|Xs], B, Aux, Salida):- (not(parteYa(X, B)), append([X], Aux, Lista), filtrarLista(Xs, B, Lista, Salida));
                                       (parteYa(X, B), filtrarLista(Xs, B, Aux, Salida)).

gitPush([N,A,F,[W,I,[NL,LCommits],[NR,RCommits]]], RepoOutput):- filtrarLista(LCommits, RCommits, [], Aux), append(Aux, RCommits, Aux2), RepoOutput =[N,A,F,[W,I,[NL,LCommits],[NR,Aux2]]].


/*Teniendo esto listo, lo que nos faltaria por hacer es poder pasar a un solo string el contenido completo del Repositorio de Git,
lo cual se logrará con una funcion llamada git2String(RepoInput, RepoAsString).

para hacer todo esto, debemos saber el como unir strings y como pasar datos a strings, en el caso de que estos no esten ya como string de antemano.
luego de saber esto, haremos las siguientes funciones
listaArch2String
commit2String
commitList2String
data2String
workspace2String
index2String
repository2String
y la que los concatenará a todas:
git2String

para unir 2 strings usaremos string_concat(string1, string2, Salida).
*/
listaArch2String([X|Xs], String, Salida):- ((not(Xs = [])), string_concat(X, ', ', Aux), string_concat(String, Aux, NewString), listaArch2String(Xs, NewString, Salida));(string_concat(X, '.\n' ,Aux), string_concat(String, Aux, NewString), Salida = NewString).

commit2String([Ls, Message], String):- listaArch2String(Ls, '', Aux), atomics_to_string(['Desc: ', Message, '\n','Archivos:', Aux ,'\n'], String).

commitList2String([], String, String).
commitList2String([X|Xs], Strings, Salida):- ((not(Xs = [])), commit2String(X, ComString), atomics_to_string([Strings, ComString], Aux), commitList2String(Xs, Aux, Salida));
                                             (commit2String(X, ComString), atomics_to_string([Strings, ComString, '\n'], Aux),commitList2String(Xs, Aux, Salida)).
data2String(NR, NA, TimeAndDate, Out):- string_concat('####', NR, A1), string_concat(A1, '####', LineaRepo), string_concat('Nombre del Autor: ',NA, LineaNombre), string_concat('Fecha de Creacion: ', TimeAndDate, LineaFecha), string_concat(LineaRepo, '\n', A2), string_concat(A2, LineaNombre, A3), string_concat(A3, '\n', A4),string_concat(A4, LineaFecha, A5), string_concat(A5, '\n', Out).


workspace2String([_, LS], Salida):-(not(LS = []), listaArch2String(LS, '', ListaArch), string_concat('\nLista de Archivos en Workspace: ', ListaArch, Salida));
                                   ((LS = []), Salida = '\nLista de Archivos en el Workspace:. \n').

index2String([_, LS], Salida):-(not(LS = []), listaArch2String(LS, '', ListaArch), string_concat('Lista de Archivos en Index: ', ListaArch, Salida));
                                   ((LS = []), Salida = 'Lista de Archivos en el Index:. \n').

repository2String([NR, X], Salida):-commitList2String(X, '', ListComs), atomics_to_string(['Commits localizados en el ', NR, ':\n', ListComs], Salida).

git2String([N,A,T,[W,I,L,R]], StringOutput):-data2String(N,A,T, Datos), workspace2String(W, Workspace), index2String(I, Index), repository2String(L, Local), repository2String(R, Remo), atomics_to_string([Datos, Workspace, Index, Local, Remo], Salida), StringOutput= Salida.