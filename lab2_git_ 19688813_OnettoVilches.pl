/*Dominio:

Git: Sistema de versionamiento que permite el trabajo con 
     repositorio tanto local como remoto para el almacenamiento 
     de trabajo de codigo. Sera representado por una lista con 
     la siguiente forma:
     [Nombre del Repo, Autor, Fecha/Hora, [Zonas]].

Zonas: Representacion mediante listas de las 4 zonas principales
       de un repositorio en git.
       se representa por: 
       [Workspace, Index, Local Repository, Remote Repository].

Workspace: Carpeta que representa la zona de trabajo donde 
           se tienen los archivos, representada por:
           ["Workspace", Lista_De_Archivos].

Index: Representa una zona temporal donde se dejan los archivos
       que seran despues puestos en un commit. Se representa por:
       ["Index", Lista_De_Archivos]

Repositorio: Espacio local y remoto el cual guarda commits
             representado por una lista en la cual se almacena en
             el primer lugar el nombre distintivo del repositorio
             seguido de una lista de commits.
             ["Local/Remote Repository", Lista Commits].

Commit: Unidad basica almacenada en repositorios, indica el avance
        en un proyecto almacenado mediante una lista de archivos y 
        un mensaje descriptivo con relacion a los cambios que se
        han hecho. se representa por:
        [Litsa Archivos, Mensaje descriptivo]
Archivos: para esta representacion, los archivos se tomaran como 
          simples strings sin caracteristicas necesarias.
           Ejemplo: "Arch.txt".

Lista: Lista
String: Cadena de Caracteres.
Atomo: Elemento.
*/

/*Predicados:

asegurarString(Entrada, Salida).
parteYa(Elemento,Lista).
agregarCabeza(Elemento,Lista,NuevaLista).
agregarAWork(Repo, ListaArchivos, NuevoRepo).
delete(ListaArchivos, Archivo, ListaAuxiliar, Salida).
crearCommit(Lista, Mensaje, Commit).
filtrarLista(ListaA, ListaB, Auxiliar, Salida).
listaArch2String(Lista, String, Salida).
commit2String(Commit, StringSalida).
commitList2String(CommitList, String, Salida).
data2String(NombreRepoGit, NombreAutor, Fecha, Salida).
workspace2String(Workspace, Salida)
index2String(Index, Salida)
repository2String(Repositorio, Salida)
*/

/*Requerimientos Funcionales creados:

gitInit(NombreRepo, Autor, RepoOutput).
gitAdd(RepoInput, ListaArch, RepoOutput).
gitCommit(RepoInput, Mensaje, RepoOutput).
gitPush(RepoInput, RepoOutput).
git2String(RepoInput, StringOut).
*/

/*-----------Hechos------------------*/
workspace(["Workspace", []]).
index(["Index", []]).
localRepo(["Local Repository", []]).
remoteRepo(["Remote Repository",[]]).

/*-----------Reglas-------------*/
%Predicado que permite convertir a string, de ser necesario, un elemento.
asegurarString(Entrada, Salida):-(not(string(Entrada)), atom_string(Entrada, Aux), Salida=Aux);(string(Entrada), Salida = Entrada).

%Predicado que permite saber si es que un elemento ya forma parte de una lista entregada
parteYa(X,[X|_]).
parteYa(X,[_|Xs]):- parteYa(X,Xs).

%Predicado que permite el agregar un elemento a la cabeza de una lista.
agregarCabeza(X,[],[X]).
agregarCabeza(X,[Y|Ys], [X, Y|Ys]).

%Predicado auxiliar que permite el agregar archivos de manera manual al Workspace.
agregarAWork(Z, [], Z).
agregarAWork([N,A,F,[[Nombre,Cont],I,L,R]], [X|Xs], Out):- asegurarString(X,Aux),(((parteYa(Aux, Cont)), agregarAWork([N,A,F,[[Nombre,Cont],I,L,R]], Xs, Out));
                                                           (agregarCabeza(Aux, Cont, Aux2),agregarAWork([N,A,F,[[Nombre,Aux2],I,L,R]], Xs, Out))).

%Predicado para eliminar el elemento dado de una lista (si es que se encuentra)
delete([], _, Auxiliar, Auxiliar).
delete([X], X, Auxiliar, Auxiliar).
delete([X| Xs], X, Aux, Out):- append(Aux, Xs , Aux2), delete([], _, Aux2, Out).
delete([X| Xs], A, Aux, Out):- append(Aux, [X], Aux2), delete(Xs, A, Aux2, Out).

%Predicado que crea un commit con la lista de Archivos y el mensaje.
crearCommit(Lista, Mensaje, [Lista, Mensaje]).

%Predicado que retorna una lista de elementos en la Lista A que no estan dentro de la Lista B.
filtrarLista([], _, Aux, Aux).
filtrarLista([X|Xs], B, Aux, Salida):- (not(parteYa(X, B)), append([X], Aux, Lista), filtrarLista(Xs, B, Lista, Salida));
                                       (parteYa(X, B), filtrarLista(Xs, B, Aux, Salida)).

%Predicados que transforma una lista de archivos a solo un string
listaArch2String([X|Xs], String, Salida):- ((not(Xs = [])), string_concat(X, ', ', Aux), string_concat(String, Aux, NewString), listaArch2String(Xs, NewString, Salida));(string_concat(X, '.\n' ,Aux), string_concat(String, Aux, NewString), Salida = NewString).

%Predicado que genera un string a partir de un commit.
commit2String([Ls, Message], String):- listaArch2String(Ls, '', Aux), atomics_to_string(['Desc: ', Message, '\n','Archivos:', Aux ,'\n'], String).

%Predicado que convierte a string una lista de commits (usando commit2String)
commitList2String([], String, String).
commitList2String([X|Xs], Strings, Salida):- ((not(Xs = [])), commit2String(X, ComString), atomics_to_string([Strings, ComString], Aux), commitList2String(Xs, Aux, Salida));
                                             (commit2String(X, ComString), atomics_to_string([Strings, ComString], Aux),commitList2String(Xs, Aux, Salida)).

%Predicado que crea un string con los datos del Repositorio de Git.
data2String(NR, NA, TimeAndDate, Out):- string_concat('####', NR, A1), string_concat(A1, '####', LineaRepo), string_concat('Nombre del Autor: ',NA, LineaNombre), string_concat('Fecha de Creacion: ', TimeAndDate, LineaFecha), string_concat(LineaRepo, '\n', A2), string_concat(A2, LineaNombre, A3), string_concat(A3, '\n', A4),string_concat(A4, LineaFecha, A5), string_concat(A5, '\n', Out).

%Predicado que convierte el Workspace a un string.
workspace2String([_, LS], Salida):-(not(LS = []), listaArch2String(LS, '', ListaArch), string_concat('\nLista de Archivos en Workspace: ', ListaArch, Salida));
                                   ((LS = []), Salida = '\nLista de Archivos en el Workspace:. \n').

%Predicado que convierte el Index a un String.
index2String([_, LS], Salida):-(not(LS = []), listaArch2String(LS, '', ListaArch), string_concat('Lista de Archivos en Index: ', ListaArch, Salida));
                                   ((LS = []), Salida = 'Lista de Archivos en el Index:. \n').

%Predicado que convierte un Repositorio (local o remoto) a solo un string.
repository2String([NR, X], Salida):-commitList2String(X, '', ListComs), atomics_to_string(['Commits localizados en el ', NR, ':\n', ListComs], Salida).

%####################################################%

%Predicado que genera un Repositorio Git en Blanco con los datos de identificacion dados.
gitInit(NombreRepo, Autor, RepoOutput):- get_time(Time), convert_time(Time, Date), workspace(W), index(I), localRepo(L), remoteRepo(R), asegurarString(NombreRepo, Aux1), asegurarString(Autor, Aux2),  RepoOutput = [Aux1, Aux2, Date, [W, I, L, R]].

%Predicado que permite agregar archivos del Workspace y los mueve al Index
gitAdd(Z, [], Z).
gitAdd([N,A,F,[[NW,Work],[NI,Ind],L,R]], [Xa|Xs] , RepoOutput):- asegurarString(Xa, X),((parteYa(X, Work), not(parteYa(X, Ind)), agregarCabeza(X, Ind, AuxI), delete(Work, X, [], AuxW), gitAdd([N,A,F,[[NW,AuxW],[NI,AuxI],L,R]], Xs , RepoOutput));
                                                         (not(parteYa(X, Work)), gitAdd([N,A,F,[[NW,Work],[NI,Ind],L,R]], Xs , RepoOutput));
                                                         (parteYa(X, Work), parteYa(X, Ind), delete(Work, X, [], AuxW), gitAdd([N,A,F,[[NW,AuxW],[NI,Ind],L,R]], Xs , RepoOutput))).

%Predicado que crea un commit y lo guarda en el repositorio local, el index es limpiado. 
gitCommit([N,A,F,[W,[NI,Ind],[NL,LCommits],R]], Mensaje, RepoOutput):- (not(Ind = []), asegurarString(Mensaje, Aux),crearCommit(Ind, Aux,Commit), append([Commit], LCommits, AuxL), RepoOutput= [N,A,F,[W,[NI,[]],[NL,AuxL],R]]); (RepoOutput = [N,A,F,[W,[NI,Ind],[NL,LCommits],R]]). 

%Predicado que copia los ultimos commits realizados y los guarda en el repositorio Remoto.
gitPush([N,A,F,[W,I,[NL,LCommits],[NR,RCommits]]], RepoOutput):- filtrarLista(LCommits, RCommits, [], Aux), append(Aux, RCommits, Aux2), RepoOutput =[N,A,F,[W,I,[NL,LCommits],[NR,Aux2]]].

%Predicado que usa los auxiliares para generar un String con el estado actual del repositorio de Git
git2String([N,A,T,[W,I,L,R]], StringOutput):-data2String(N,A,T, Datos), workspace2String(W, Workspace), index2String(I, Index), repository2String(L, Local), repository2String(R, Remo), atomics_to_string([Datos, Workspace, Index, Local, Remo], Salida), StringOutput= Salida.