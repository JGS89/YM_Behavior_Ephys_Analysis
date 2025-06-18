%% detectar_TTL_openmv.m
%--------------------------------------------------------------------------
% detectar_TTL_openmv - Detecta eventos TTL en el canal digital 0 
% registrados en archivos .rhd (Intan RHD2000) y determina el tiempo 
% de inicio y fin de grabaci�n de la c�mara OpenMV M7.
%
% FUNCIONALIDAD:
%   - Carga un archivo .rhd de registro neuronal.
%   - Extrae y grafica los datos del canal digital 0.
%   - Identifica el primer pulso ON (1) y el primer OFF (0) posterior.
%   - Devuelve el tiempo en segundos del inicio y fin de la se�al TTL,
%     correspondiente a la sincronizaci�n con la c�mara.
%
% INPUT:
%   - Archivo .rhd generado por el sistema Intan (adquisici�n neuronal).
%
% OUTPUT:
%   - Tiempo de encendido (TTL ON): inicio de la grabaci�n de c�mara.
%   - Tiempo de apagado (TTL OFF): finalizaci�n de la grabaci�n.
%   - Mensaje en consola para copiar los valores manualmente a TTLS.xlsx.
%
% REQUISITOS:
%   - Debe tener la funci�n `read_Intan_RHD2000_file.m` en el path de trabajo.
%
% AUTOR:
%   Javier Gonzalez Sanabria, PhD  
%   javiergs89@gmail.com  
%   Marzo 2022
%--------------------------------------------------------------------------

clc; clear all; close all;

%% Seleccionar archivo .rhd
[file, path, ~] = uigetfile('*.rhd', 'Seleccionar archivo de datos Intan (.rhd)', 'MultiSelect', 'off');
if file == 0
    return; % Salir si el usuario cancela
end

%% Leer archivo
read_Intan_RHD2000_file(file, path);

%% Graficar canal digital 0
figure(1);
plot(t_dig, board_dig_in_data);
xlabel('Tiempo (s)');
ylabel('TTL (canal digital 0)');
title('Se�al TTL - Canal Digital 0');
axis tight;

%% Detectar transiciones TTL
idx_led1 = find(board_dig_in_data > 0);  % TTL ON
idx_led0 = find(board_dig_in_data == 0); % TTL OFF

tpo_led_1 = t_dig(idx_led1(1));  % Primer subida TTL
tpo_led_0 = t_dig(idx_led0(find(idx_led0 > idx_led1(1), 1))); % Primer bajada posterior

%% Reportar tiempos
if tpo_led_1 < tpo_led_0
    disp(['>>> Comienzo (ON) de la tarea es: ', num2str(tpo_led_1), ' seg']);
    disp(['>>> Final (OFF) de la tarea es: ', num2str(tpo_led_0), ' seg']);
else
    disp('>>> Advertencia: TTL invertido o valores inconsistentes.');
end

disp('>>> Copiar valores de tiempo en archivo TTLS.xlsx correspondiente a la sesi�n.');