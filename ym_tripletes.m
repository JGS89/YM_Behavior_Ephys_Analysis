function [ABC_count, total_triplets, alternance_percent] = ym_tripletes(sequence)
% --------------------------------------------------------------
% Calcula alternancias tripletes en una prueba de Y-Maze
% INPUT:
%   sequence : vector columna o fila con la secuencia de brazos visitados (e.g., [1 2 3 2 1 3 ...])
%
% OUTPUT:
%   ABC_count         : cantidad de tripletes únicos (sin repeticiones)
%   total_triplets    : total de tripletes posibles (n-2)
%   alternance_percent: porcentaje de alternancia correcta ABC respecto del total
%
% Autor: JGS | Versión mejorada 2025
% --------------------------------------------------------------

    % Asegurar formato columna
    a = sequence(:);
    n = length(a);

    % Inicializar contador
    ABC_count = 0;

    % Recorrer cada triplete
    for i = 1:(n-2)
        triplet = a(i:i+2);
        % Verifica si los 3 elementos son distintos entre sí
        if numel(unique(triplet)) == 3
            ABC_count = ABC_count + 1;
        end
    end

    % Calcular total de tripletes posibles
    total_triplets = n - 2;

    % Calcular porcentaje de alternancia
    if total_triplets > 0
        alternance_percent = (ABC_count / total_triplets) * 100;
    else
        alternance_percent = NaN;
        warning('Secuencia demasiado corta para formar tripletes.')
    end
end