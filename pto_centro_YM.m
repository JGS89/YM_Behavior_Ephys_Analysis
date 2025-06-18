%% ===============================================
%% SELECCIÓN DEL PUNTO CENTRAL EN Y-MAZE (YM)
%% ===============================================
% Este script permite seleccionar manualmente el punto central del Y-maze
% a partir del tracking registrado durante una sesión.
%
% El punto seleccionado debe guardarse en el archivo "YM_cordcenter.xlsx"
% para que pueda ser leído por los scripts de análisis posteriores.
%
% IMPORTANTE:
% - El archivo .mat de la sesión debe contener variables de tracking:
%   Pos_X_YM y Pos_Y_YM (posiciones reescaladas y sincronizadas con tiempo).
%
% Autor: JGS
% Año: 2025
% -----------------------------------------------
clear, clc, close all
%% Seleccion de la sesion .mat
[File, folder] = uigetfile('*.mat', 'Seleccionar archivo de sesión');
if isequal(File,0)
    disp('>> Cancelado por el usuario');
    return;
end
load(fullfile(folder, File));
%% Cargar la sesion de interes "aammdd.mat"
x = Pos_X_YM(Pos_X_YM(:,1)>1);
y = Pos_Y_YM(Pos_Y_YM(:,1)>1);
time = Pos_X_YM((Pos_X_YM(:,1)>1),2);
a = x;
x = y;
y = a;
clear a
y1 = -y;
y = y1 + abs(min(y1));
fig1 = figure;
plot(x,y)
title('Seleccionar pto centro del YM')
[xi, yi] = ginput(1);
hold on
text(xi,yi, [ '(', num2str(xi), ', ', num2str(yi), ')' ],...
        'Color','red','FontSize',18);
disp(['Valor de centro en x: ', num2str(xi)])
disp(['Valor de centro en y: ', num2str(yi)])

centro = [xi, yi];
plus_armB = +2;
crit_time_f = 960; % 16 mins
cota = find(time<time(1,1)+crit_time_f, 1, 'last');
xx = x(1:cota); yy = y(1:cota); timet = time(1:cota); % 0-16 mins
YM_completo = [ xx, yy, timet ];
Crit = 7;
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
figure
plot(Brazo_A(:,1),Brazo_A(:,2),'.'), axis tight
hold on
plot(Brazo_B(:,1),Brazo_B(:,2),'.'), axis tight
plot(Brazo_C(:,1),Brazo_C(:,2),'.'), axis tight
plot(Centro(:,1),Centro(:,2),'.'), axis tight
YM_ABC = cell(1,3);
YM_ABC{1,1} = Brazo_A;
YM_ABC{1,2} = Brazo_B;
YM_ABC{1,3} = Brazo_C;
