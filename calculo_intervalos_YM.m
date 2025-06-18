%%% ==========================================================
%%% CÁLCULO DE INTERVALOS POR TAREA PARA SESIONES - Y-MAZE (YM)
%%% Autor: J.G.S. – Última actualización: JUN 2025
%%% Requiere:
%%%   - Archivo .mat con variables Pos_X_YM y Pos_Y_YM (tracking 2D)
%%%   - Funciones: celda_intervalos_YM.m
%%% Salida:
%%%   - Variable: ints_YM ? celda con intervalos por tipo de evento
%%% ==========================================================

clear; close all; clc;

%% === CARGA DE SESIÓN (.mat) ===
[File, folder] = uigetfile('C:\Users\JGS\Desktop\JGS', ...
    'Seleccionar sesión (*.mat)', '*.mat');
load(fullfile(folder, File));  % Carga el archivo de sesión

% Extrae fecha desde nombre del archivo (formato: 'YYMMDD_...')
fecha = File(1:6);             

%% === IDENTIFICACIÓN DEL ANIMAL ===
animal = input('>> Ingrese el ID del animal: ');

%% === ADVERTENCIA: VERIFICAR VARIABLES DE TRACKING ===
% Asegurarse que existan las variables Pos_X_YM y Pos_Y_YM en el .mat
% Estas deben estar reescaladas si es necesario (con rutina previa)
% y en el formato requerido por celda_intervalos_YM.m

%% === CÁLCULO DE INTERVALOS (YM) ===
% Esta función devuelve una celda con los siguientes tipos de intervalos:
%   1) Corridas hacia el punto central
%   2) Corridas hacia la periferia
%   3) Corridas hacia el centro (solo secuencias correctas)
%   4) Corridas hacia la periferia (solo secuencias correctas)
%   5) Corridas hacia el centro (solo secuencias incorrectas)
%   6) Corridas hacia la periferia (solo secuencias incorrectas)

ints_YM = celda_intervalos_YM(str2double(fecha), animal, Pos_X_YM, Pos_Y_YM);

%% === GUARDADO DE RESULTADOS ===
save(fecha, 'ints_YM')  % Guarda bajo el nombre de la fecha (por seguridad)

%% === FINALIZACIÓN ===
disp('%%%%% < F I N A L I Z A D O > %%%%%')   