%% PHASE LOCKING ANALYSIS: LFP (HP) to mPFC NEURONS %%
% Versión Flor-Javi 2025 – Adaptado para tareas tipo Y-Maze (YM)
% ---------------------------------------------------------------
% Descripción:
% Este script evalúa el acoplamiento de fase entre señales LFP del hipocampo
% (HP) y la actividad de neuronas del mPFC durante tareas de comportamiento.
% Calcula la fase instantánea de LFP (Hilbert transformada de señal filtrada 6–10 Hz),
% asigna fase a spikes, y usa la prueba de Rayleigh para evaluar uniformidad circular.
%
% Salidas por neurona e intervalo:
% - p: p-valor (Rayleigh)
% - theta: ángulo medio (fase dominante)
% - rbar: longitud del vector resultante
% - delta: dispersión circular
% - tag_sn: 1 si p<0.05, 0 si no
%
% Requiere:
% - Variables tipo `nr_*` (spikes), `LFP_HP*`, `Pos_X_YM`, `Pos_Y_YM`
% - Scripts: `celda_intervalos_YM`, `rayleigh.m`

%% Inicialización
clear; close all; clc;

%% Selección del archivo de sesión (.mat)
[File, myPath] = uigetfile('', ...
                           'Seleccione archivo de sesión *.mat', '*.mat');
load([myPath, File]);
datos = who;
idx_neuronas = find(strncmp(datos, 'nr_', 3));

%% Parámetros generales
tarea = 'YM';          % Tipo de tarea
chLFP = 4;             % Canal de LFP a usar
freqmLFP = 1250;       % Frecuencia de muestreo del LFP

% Filtro Butterworth en banda theta (6–10 Hz)
LowCut = 6 / (freqmLFP/2);
HighCut = 10 / (freqmLFP/2);

%% Selección y verificación del LFP
LFP_str = who('-regexp', 'LFP');
LFP_string = LFP_str(1:end-1); % Elimina freqLFP
LFP_HP = eval("LFP_HP" + int2str(chLFP));

%% Generación de intervalos (si no existen)
if ~exist('ints_YM', 'var')
    fecha = File(1:6);
    animal = input('>> Número de animal? ');
    ints_YM = celda_intervalos_YM(str2double(fecha), animal, Pos_X_YM, Pos_Y_YM);
end

% Unifica intervalos de corrida (centro y periferia)
celda_intervalos{1,1} = [ints_YM{1,1}; ints_YM{2,1}];
celda_intervalos{1,2} = 'AllRuns';
celda_intervalos = [celda_intervalos; ints_YM];

%% Inicialización de variables
animal = myPath(end-2:end-1);
if isnan(str2double(animal))
    animal = str2double(animal(2));
end
if isnan(animal)
    animal = str2double(myPath(44:45));
end
fecha = str2double(File(1:6));

orden_neu = cell(length(idx_neuronas), 1);         % Nombres de neuronas
Rayleigh = cell(length(idx_neuronas), 1);          % Resultados por neurona
Ray_all_intervalos = cell(length(celda_intervalos), 1);  % Resultados por intervalo
nro_spikes = cell(length(celda_intervalos), 1);    % Spikes por neurona e intervalo

tags_inter = {'AllRuns', 'toCenter', 'toPerifery', ...
              'toCenterCorrect', 'toCenterIncorrect', ...
              'toPeriferyCorrect', 'toPeriferyIncorrect'};

%% Análisis principal por grupo de intervalos
for grup = 1:length(celda_intervalos)
    fase_seg_acum = cell(length(idx_neuronas), 1);

    % Si está vacío, continúa
    try
        mustBeNonempty(celda_intervalos{grup,1});
    catch
        Ray_all_intervalos{grup,1} = NaN(length(idx_neuronas), 6);
        continue
    end

    intervalos = celda_intervalos{grup,1};
    nro_spikes{grup,1} = zeros(length(idx_neuronas),1);

    for i = 1:size(intervalos,1)
        % Extrae segmento de LFP
        inicio = find(LFP_HP(:,2) >= intervalos(i,1), 1, 'first');
        final = find(LFP_HP(:,2) <= intervalos(i,2), 1, 'last');
        lfp_int = LFP_HP(inicio:final, :);

        % Filtrado bidireccional para evitar desplazamiento de fase
        [B,A] = butter(3, [LowCut, HighCut]);
        lfp_filt1 = filtfilt(B, A, lfp_int(:,1));
        lfp_reversed = fliplr(lfp_filt1);
        lfp_filt2 = filtfilt(B, A, lfp_reversed);
        lfp_filt = fliplr(lfp_filt2);

        % Fase instantánea
        hilb = hilbert(lfp_filt);
        fase_int_all = angle(hilb);

        % Fase de spikes por neurona
        for n = 1:length(idx_neuronas)
            neurona = eval(datos{idx_neuronas(n)});
            try
                neu_inicio = find(neurona >= LFP_HP(inicio,2), 1, 'first');
                neu_final  = find(neurona <= LFP_HP(final,2), 1, 'last');
                neu_segm = neurona(neu_inicio:neu_final);
            catch
                continue
            end

            fase_seg = zeros(length(neu_segm), 1);
            for k = 1:length(neu_segm)
                idx_spk = find(neu_segm(k) <= lfp_int(:,2), 1, 'first');
                fase_seg(k) = fase_int_all(idx_spk);
            end
            fase_seg_acum{n} = [fase_seg_acum{n}; fase_seg];
            nro_spikes{grup,1}(n,1) = nro_spikes{grup,1}(n,1) + length(fase_seg);
            orden_neu{n} = datos{idx_neuronas(n)};
        end
    end

    % Cálculo de Rayleigh para cada neurona
    for neu = 1:length(idx_neuronas)
        [p, theta, rbar, delta] = rayleigh(fase_seg_acum{neu});
        tag_sn = p < 0.05;
        Rayleigh{neu} = [p, theta, rbar, delta, tag_sn];
    end

    % Consolida resultados
    Ray_all = [];
    for i = 1:length(Rayleigh)
        Ray_all = [Ray_all; Rayleigh{i}];
    end
    Ray_all_intervalos{grup,1} = [Ray_all(:,1:4), nro_spikes{grup,1}, Ray_all(:,5)];
    
    %% Plot Rosettas
    fig = figure(grup);
    fig.Position = [ 1 1 800 800 ];
    sup = suptitle(tags_inter{grup});
    sup.FontSize = 11;
    sup.Position = [ 0.5 -0.03 0 ];
    for g = 1:length(idx_neuronas)
        y = ceil(length(idx_neuronas)/5)+2; % esto me da el tamaño de la figura, para que entren todas las neuronas
        % ver de ajustar de acuerdo al número de neuronas de cada sesión
        subplot(y,y,g) 
        h = polarhistogram(fase_seg_acum{g},18); %nbins = 18 (R.Alvarez)
        set(gca,'FontSize',10)
        hold on
        %para graficar vector resultante 
        th = Rayleigh{g}(1,2);
        r = Rayleigh{g}(1,3);
        polarscatter(th,r,'filled');
        h.FaceAlpha = 0.3;

        if Rayleigh{g,1}(1,1) < 0.05
            h.FaceColor = 'r';
        else
            h.FaceColor = 'b';
        end
        title({orden_neu{g};['p = ',num2str(round(Rayleigh{g,1}(1,1),3)),...
            ', r = ',num2str(round(Rayleigh{g,1}(1,3),2))];...
            ['ang = ', num2str(round(rad2deg(Rayleigh{g,1}(1,2)),2))]},...
            'FontSize',9)
%         text(1,3,num2str(round(rad2deg(Rayleigh{g,1}(1,2)),2)), 'FontSize', 6)

      
    end
end

%% Exportar resultados (opcional)
For_paste = [];
for i = 1:length(Ray_all_intervalos)
    For_paste = [For_paste, Ray_all_intervalos{i,1}];
end

disp('>> Análisis de Phase Locking finalizado correctamente.')