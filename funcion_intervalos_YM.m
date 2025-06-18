function Celda_intervalos = funcion_intervalos_YM(fecha, animal, pos_x, pos_y)
%--------------------------------------------------------------------------
% funcion_intervalos_YM - Calcula intervalos de comportamiento en el Y-Maze 
% a partir de las posiciones espaciales del animal bidimensional (X, Y).
%
% Esta función analiza trayectorias del animal en un laberinto en Y (Y-Maze)
% para identificar y clasificar eventos de transición entre bin CENTRO y
% bin PERIFERIA, y distinguir si dichas transiciones son correctas o incorrectas 
% según alternancia de 3 brazos (memoria espacial).
%
% INPUTS:
%   fecha   - String con la fecha de la sesión experimental ('aammdd')
%   animal  - String o número identificador del animal (ej '07')
%   pos_x   - Vector Nx2 con coordenadas X y tiempo: [X  tiempo]
%   pos_y   - Vector Nx2 con coordenadas Y y tiempo: [Y  tiempo]
%
% OUTPUT:
%   Celda_intervalos - Celda 6x2 con los siguientes intervalos de comportamiento:
%       {1,1} - Intervalos de entrada al centro ('toCenter')
%       {2,1} - Intervalos de salida hacia una periferia ('toPerifery')
%       {3,1} - Entradas al centro con alternancia correcta ('toCenterCorrect')
%       {4,1} - Entradas al centro con alternancia incorrectas ('toCenterIncorrect')
%       {5,1} - Salidas hacia periferia con alternancia correcta ('toPeriferyCorrect')
%       {6,1} - Salidas hacia periferia con alternancia incorrecta ('toPeriferyIncorrect')
%
%   {x,2} - Nombre del tipo de intervalo correspondiente (string descriptivo)
%
% NOTAS:
%   - El layout del laberinto en Y y las zonas (centro/periferia) están 
%   predefinidas en la lógica interna de la función.
%   - El criterio de "correcto/incorrecto" depende del paradigma de
%   alternancia espontánea.
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------

x = pos_x( pos_x(:,1) > 1 );
y = pos_y(pos_y(:,1)>1);
time = pos_x((pos_x(:,1)>1),2);

%% para INVERTIR de AbC YM a aBc
% todos los analisis deben hacerse en formato aBc (brazo B vectical sup centro)

file = 'C:\Users\JGS\Desktop\JGS\DATOS sesiones\YM_cordcenter.xlsx';
filexlsx = xlsread(file,1);
data = filexlsx(2:end,:);
girar = unique(data(data(:,1) == animal & data(:,2) == fecha, 5));
inver = unique(data(data(:,1) == animal & data(:,2) == fecha, 6));

% Se rota el maze segun col 4:5 de YM_cordcenter.xlsx
% girar = input('Rotar 90° YM? (Y:1/N:0): ');
if girar == 1
    a = x;
    x = y;
    y = a;
    clear a
end
% close all
% plot(x,y), axis tight
% inver = input('Rotar YM eje vertical? (Y:1/N:0): ');
if inver == 1
    y1 = -y;
    y = y1 + abs(min(y1));
end
close all

%% UPSAMPLE tracking a 10 Hz ts_up = 1/10;
ts_up = 1/10;
new_timeline = time(1):ts_up:time(end);
x_origin = timeseries(x, time);
y_origin = timeseries(y, time);
x_resample = resample(x_origin, new_timeline);
y_resample = resample(y_origin, new_timeline);
% descarto los 2 primeros frames artefacto tracking
x = x_resample.data(3:end);
y = y_resample.data(3:end);
time = new_timeline(3:end)';

clear new_timeline, clear x_origin, clear y_origin
clear x_resample, clear y_resample
%% Tiempos criticos para seleccion de bloques
crit_time = 480; % 8 mins
crit_time_f = 960; % 16 mins

bloque = 1; % se considera toda la tarea, modificar si se considera otro bloque

if bloque == 1
    cota = find(time<time(1,1)+crit_time_f, 1, 'last');
    xx = x(1:cota); yy = y(1:cota); timet = time(1:cota); % 0-16 mins
    YM_completo = [ xx, yy, timet ];
elseif bloque == 2
    cota = find(time<time(1,1)+crit_time, 1, 'last');
    xx = x(1:cota); yy = y(1:cota); timet = time(1:cota); % 0-8 mins
    YM_completo = [ xx, yy, timet ];
elseif bloque == 3
    cota = find(time>time(1,1)+crit_time, 1, 'first');
    cota_f = find(time<time(1,1)+crit_time_f, 1, 'last');
    xx = x(cota:cota_f); yy = y(cota:cota_f); timet = time(cota:cota_f); % 8-16mins
    YM_completo = [ xx, yy, timet ];
end

clear cota
YM_completo(1,1:2) = YM_completo(2,1:2); % correccion de artefacto primer punto
% plot(x,y), axis tight
%% SELECCION DEL CENTRO DEL MAZE segun YM_cordcenter.xlsx
% title('Seleccionar el centro del YM')
% Elegir centro del maze
% [ xc, yc ] = ginput(1); % seleccionar punto centrar del Ymaze
% centro = [ xc yc ];
data = filexlsx(2:end,:);
xc = unique(data(data(:,1) == animal & data(:,2) == fecha, 3));
yc = unique(data(data(:,1) == animal & data(:,2) == fecha, 4));
centro = [ xc yc ];
%
if ismember(animal,[ 7 8 10 ])
    Crit = 10;
else
    Crit = 7;
end

if inver == 1
    plus_armB = +2;
else
    plus_armB = -2;
end
close all
%% Asignacion de cada brazo del YM
Brazo_A = [];
Brazo_B = [];
Brazo_C = [];
Centro = [];
for i = 1:length(YM_completo)
    if YM_completo(i,1) < centro(1) - Crit && YM_completo(i,2) < centro(2)
        Brazo_A = [ Brazo_A; YM_completo(i,:) ];% Brazo A
    elseif YM_completo(i,2) > centro(2)+Crit+plus_armB
        Brazo_B = [ Brazo_B; YM_completo(i,:) ];% Brazo B
    elseif YM_completo(i,1) > centro(1)+Crit && YM_completo(i,2) < centro(2)
        Brazo_C = [ Brazo_C; YM_completo(i,:) ];% Brazo C
    else
        Centro = [ Centro; YM_completo(i,:) ];
    end
end
%     figure
%     plot(Brazo_A(:,1),Brazo_A(:,2),'.'), axis tight
%     hold on
%     plot(Brazo_B(:,1),Brazo_B(:,2),'.'), axis tight
%     plot(Brazo_C(:,1),Brazo_C(:,2),'.'), axis tight
%     plot(Centro(:,1),Centro(:,2),'.'), axis tight
YM_ABC = cell(1,3);
YM_ABC{1,1} = Brazo_A;
YM_ABC{1,2} = Brazo_B;
YM_ABC{1,3} = Brazo_C;

%% Reescalado de cada brazo del YM
largo_brazo_mm = 470; %Largo de cada brazo del YM
YM_ABC_Rescalado = cell(1,3);
for i = 1:length(YM_ABC)
    if i == 2 % NECESARIO INTERCAMBIAR X e Y en el BRAZO VERTICAL "B"
        X = YM_ABC{1,i}(:,2);
        Y = YM_ABC{1,i}(:,1);
    else
        X = YM_ABC{1,i}(:,1);
        Y = YM_ABC{1,i}(:,2);
    end
    Pos_x_time = YM_ABC{1,i}(:,3);
    trsh_min = min(X)+30;
    trsh_max = max(X)-30;
    pos_bi = [ X , Y ];
    y_sup = [];
    y_inf = [];
    for n = 1:length(X)
        if pos_bi(n,1) < trsh_min
            y_inf = [ y_inf pos_bi(n,2)];
        elseif pos_bi(n,1) > trsh_max
            y_sup = [ y_sup pos_bi(n,2)];
        else
        end
    end
    y_means_ext = [ mean(y_inf) mean(y_sup) ];
    x_means_ext = [ mean(X(X<trsh_min)) mean(X(X>trsh_max)) ];
    recta = [ transpose(x_means_ext) transpose(y_means_ext) ];
    m = ((recta(2,2)-recta(1,2))/(recta(2,1)-recta(1,1)));
    b0 = -m*recta(2,1)+recta(2,2);
    ang = atand((recta(2,2)-recta(1,2))/(recta(2,1)-recta(1,1))); %angulo
    x_proy = X./cosd(ang);
    x_modif = x_proy-min(x_proy);
    radio_raton_mm = 20;
    x_rescalado = radio_raton_mm+(x_modif.*(largo_brazo_mm-(radio_raton_mm*2)))./max(x_modif);
    Pos_time_modif = Pos_x_time-min(Pos_x_time);
    YM_ABC_Rescalado{1,i} = [ x_rescalado Pos_x_time ones(length(x_rescalado),1)*i ];
end
%Dar vuelta la escala del brazo A
asdf = YM_ABC_Rescalado{1,1}(:,1) - 480;
asdfg = [ abs(asdf) YM_ABC_Rescalado{1,1}(:,2) ones(length(asdf),1) ];
YM_ABC_Rescalado{1,1} = asdfg;
clear asdf, clear asdfg


Recorrido_completo = [ YM_ABC_Rescalado{1,1}; YM_ABC_Rescalado{1,2}; YM_ABC_Rescalado{1,3} ];
Recorrido_sort = sortrows(Recorrido_completo,2);
%% Celda con los datos de cada brazo, linealizados
YM_R = [ YM_ABC_Rescalado{1,1}; YM_ABC_Rescalado{1,2}; YM_ABC_Rescalado{1,3} ];
YM_R = sortrows(YM_R, 2);
% [ Celda_Inter_Names , Celda_Intervalos, Secuencia ] = funcion_intervalos_YM(YM_R);

% COMPORTAMIENTO del YM
[ ~, ~, Secuencia ] = funcion_intervalos_YM(YM_R);
[ YM_nro_Alt, YM_total, YM_Per100_Alt ] = ym_tripletes(Secuencia);
Comportamiento = [ YM_nro_Alt, YM_total, YM_Per100_Alt ];
nro_visit_arms = [ sum(Secuencia == 1) ...
    sum(Secuencia == 2) ...
    sum(Secuencia == 3) ];

close all

%% Calculo de intervalos
cant_bines = 5;
%para que los bines sean de tamaño comparable al LT
Long_bin = largo_brazo_mm/cant_bines;
Limites_bines = [0:Long_bin:largo_brazo_mm];

pos = YM_R(:,1); time = YM_R(:,2); sec = YM_R(:,3);

idx_sec = find(diff(sec)~= 0) + 1;
% Correccion para incluir brazo de partida
idx_sec = [ 1; idx_sec ];
sec_arms = [];
depur_idx_sec = [];

for n = 1:length(idx_sec)
    % CRITERIO entradas espureas: solo entradas que llegan a bin 2
    if n == length(idx_sec)
        pos_int_brazo = pos(idx_sec(n):end);
    else
        pos_int_brazo = pos(idx_sec(n):(idx_sec(n+1)-1));
    end
    % evaluar si llega a bin 2
    if max(pos_int_brazo) >= Limites_bines(2)
        sec_arms = [ sec_arms; sec(idx_sec(n)) ];
        depur_idx_sec = [ depur_idx_sec; idx_sec(n) ];
    end
    clear pos_int_brazo
end

% se corrigen los idx_sec
idx_sec = depur_idx_sec;
clear depur_idx_sec
to_centro = [];
to_perif = [];
idxs = [];
tpo_muerto = [];

% CRITERIO: no se considera la corrida de entrada a la tarea idx = 1,
% solamente se ve de que brazo comenzo para el calculo de secuencia en
% visita #2
for idx = 2:length(idx_sec)
    % el ultimo intervalo debe ir hasta el ultimo pto de pos
    
    if idx == length(idx_sec)
        ti = idx_sec(idx);
        tf = length(pos);
    else
        ti = idx_sec(idx);
        tf = idx_sec(idx+1) - 1; % corregido: tomar el ultimo idx antes de salir del brazo!
    end
    
    % Criterio de retorno modificado 22/3
    % no se usa mas el maximo sino el intervalo en bin maximo que llegue
    pos_time_idx_brazo = [ pos(ti:tf) time(ti:tf) sec(ti:tf) ];
    
    % Cual es el max bin que llega en la visita al brazo?
    max_bin_visitado = 0;
    for i = 1:cant_bines %bines
        any_pos_bin = pos_time_idx_brazo(pos_time_idx_brazo(:,1) >= Limites_bines(i),1);
        if isempty(any_pos_bin)
            continue
        else
            max_bin_visitado = max_bin_visitado + 1;
        end
    end
    
    idx_binMax = find(pos_time_idx_brazo(:,1) >= Limites_bines(max_bin_visitado));
    idx_binMin = find(pos_time_idx_brazo(:,1) < Limites_bines(2));
    
    % tiempos de entrada y salida del bin maximo al que llega!
    
    tiP = pos_time_idx_brazo(idx_binMax(1), 2);
    tfP = pos_time_idx_brazo(idx_binMax(end), 2);
    ts_ym = time(2) - time(1);
    idx_less_bin2 = find(diff(idx_binMin) > 1, 1, 'last');
    tfC = pos_time_idx_brazo(idx_binMin(idx_less_bin2+1),2);
    
    % Correccion para evitar que se quede mucho en bin Centro
    if time(tf) - tfC > 3
        t_final = tfC + 3;
    else
        t_final = time(tf);
    end
    
    if (tfP - tiP) > 3 % CRITERIO 3 seg en binMax
        
        to_perif = [ to_perif; time(ti) tiP+3 ];
        if t_final - tfP-3 > 10 % tolerancia 10 seg de retorno
            to_centro = [ to_centro; t_final-10 t_final ];
        else
            to_centro = [ to_centro; tfP-3 t_final ];
        end
        idxs = [ idxs; pos_time_idx_brazo(find...
            (max(pos_time_idx_brazo(:,1))), 3) ];
        tpo_muerto = [ tpo_muerto; tiP+3 tfP-3 ];
        
    else % sino se van a solapar las pasadas por el binMax
        
        to_perif = [ to_perif; time(ti) tfP ];
        if t_final - tiP > 10 % tolerancia 10 seg de retorno
            to_centro = [ to_centro; t_final-10 t_final ];
        else
            to_centro = [ to_centro; tiP t_final ];
        end
        idxs = [ idxs; pos_time_idx_brazo(find...
            (max(pos_time_idx_brazo(:,1))), 3) ];
        
    end
end


clear data
%% Armo la matriz de todos los intervalos
data = [ to_centro ones(length(to_centro),1) zeros(length(to_centro),1) idxs;...
    to_perif zeros(length(to_perif),1) ones(length(to_perif),1) idxs ];
data = sortrows(data, 1, 'ascend');

clear Intervalos
Intervalos = cell(6,2);
Intervalos{1,2} = 'toCenter';
Intervalos{2,2} = 'toPerifery';
Intervalos{3,2} = 'toCenterCorrect';
Intervalos{4,2} = 'toCenterIncorrect';
Intervalos{5,2} = 'toPeriferyCorrect';
Intervalos{6,2} = 'toPeriferyIncorrect';

Intervalos{1,1} = [ to_centro idxs ];
Intervalos{2,1} = [ to_perif idxs ];

for n = 2 : length(sec_arms)-1
    v = [ sec_arms(n-1) sec_arms(n) sec_arms(n+1) ];
    if length(v) == length(unique(v)) % CORRECT!
        if data( data(:,1) == time(idx_sec(n)) , 4) == 1
            Intervalos{5,1} = [ Intervalos{5,1}; data( data(:,1) == time(idx_sec(n)) , 1:2 ) data( data(:,1) == time(idx_sec(n)) , 5 ) ];
            Intervalos{3,1} = [ Intervalos{3,1}; data( find(data(:,1) == time(idx_sec(n))) + 1 , 1:2 ) data( find(data(:,1) == time(idx_sec(n))) + 1 , 5 ) ];
        end
    else % INCORRECT!
        if data( data(:,1) == time(idx_sec(n)) , 4) == 1
            Intervalos{6,1} = [ Intervalos{6,1}; data( data(:,1) == time(idx_sec(n)) , 1:2 ) data( data(:,1) == time(idx_sec(n)) , 5 ) ];
            Intervalos{4,1} = [ Intervalos{4,1}; data( find(data(:,1) == time(idx_sec(n))) + 1 , 1:2 ) data( find(data(:,1) == time(idx_sec(n))) + 1 , 5 ) ];
        end
    end
end

%%% CONTROL SUMA DE INTERVALOS tot = cor + inc
sum_tot_center = sum(diff(Intervalos{1,2}(:,1:2),[],2));
sum_cor_center = sum(diff(Intervalos{3,2}(:,1:2),[],2));
sum_inc_center = sum(diff(Intervalos{5,2}(:,1:2),[],2));
diff_center = sum_tot_center - sum_cor_center - sum_inc_center;

% Correccion ultimo intervalo que no entra en clasificacion cor/inc
if (length(Intervalos{1,2})...
        - length(Intervalos{3,2})...
        - length(Intervalos{4,2})) == 1
    Intervalos{1,2}(end,:) = [];
end

if (length(Intervalos{2,2})...
        - length(Intervalos{5,2})...
        - length(Intervalos{6,2})) == 1
    Intervalos{2,2}(end,:) = [];
end

%% Output final
Celda_intervalos = Intervalos;
% Finalizado...
end