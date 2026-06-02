clear;
clc;
%close all;

pcapFile = 'aquisition2.pcap';
jsonFile = 'aquisition2.json';

% total_frames nous donne combien j'ai de Frame 
reader_rapide = ousterFileReader(pcapFile, jsonFile);
total_frames = 0;
while hasFrame(reader_rapide)
    readFrame(reader_rapide);
    total_frames = total_frames + 1;
end

% Netoiyage 
frame_ingoner = 2; % On ignore les 2 frame premier et fin 
frame_debut = frame_ingoner + 1;
frame_fin = total_frames - frame_ingoner;
nb_frames_utiles = frame_fin - frame_debut + 1; % C'est le nombre total de frames que l'on va réellement garder pour la moyenne et la variance.

% lire encor une fois le fichier avec le debut de frame netoiyer 
reader = ousterFileReader(pcapFile, jsonFile);

% On saute le début de l'enregistrement
for i = 1:(frame_debut - 1)
    readFrame(reader); % matlab lit la frame mais la suprme apres vu que le l'on stock pas et le curseur bouge jusqua notre frame de debut netoiyer 
end

% LECTURE AVEC EXTRACTION DES DONNÉES (On lit la première frame utile)
[ptCloud, pcAttributes] = readFrame(reader); 
ptCloud_Visu = ptCloud; % On met la première image de côté pour l'affichage final du nuage de points

[LIGNES, COLONNES, ~] = size(ptCloud.Location); 
disp(['Résolution détectée par MATLAB : ', num2str(LIGNES), ' lignes et ', num2str(COLONNES), ' colonnes.']);

% Création des matrices de stockage pour les DEUX méthodes
%Distances_XYZ  = zeros(LIGNES, COLONNES, nb_frames_utiles, 'single');
%Distances_RAW  = zeros(LIGNES, COLONNES, nb_frames_utiles, 'single');

Distances_XYZ  = zeros(LIGNES, COLONNES, nb_frames_utiles);
Distances_RAW  = zeros(LIGNES, COLONNES, nb_frames_utiles);

% Pixel cobaye défini au début pour pouvoir extraire son historique X,Y,Z pendant la boucle
point_L = 64;
point_C = 512;

% Pré-allocation de l'historique X, Y, Z pour notre pixel single -> pour 32
% bite au lieux de 64 bite
%hist_X = zeros(nb_frames_utiles, 1, 'single');
%hist_Y = zeros(nb_frames_utiles, 1, 'single');
%hist_Z = zeros(nb_frames_utiles, 1, 'single');
hist_X = zeros(nb_frames_utiles, 1);
hist_Y = zeros(nb_frames_utiles, 1);
hist_Z = zeros(nb_frames_utiles, 1);
% On stocke la 1ère frame utile
%Distances_XYZ(:,:,1) = single(sqrt(ptCloud.Location(:,:,1).^2 + ptCloud.Location(:,:,2).^2 + ptCloud.Location(:,:,3).^2));
%Distances_RAW(:,:,1) = single(double(pcAttributes.Range));
Distances_XYZ(:,:,1) = sqrt(ptCloud.Location(:,:,1).^2 + ptCloud.Location(:,:,2).^2 + ptCloud.Location(:,:,3).^2);
Distances_RAW(:,:,1) = double(pcAttributes.Range);

hist_X(1) = ptCloud.Location(point_L, point_C, 1);
hist_Y(1) = ptCloud.Location(point_L, point_C, 2);
hist_Z(1) = ptCloud.Location(point_L, point_C, 3);

% On boucle sur le reste des frames utiles pour remplir le tableau
disp('Extraction des données XYZ et RAW en cours...');
for k = 2:nb_frames_utiles
    [ptCloud, pcAttributes] = readFrame(reader);
    
    %Distances_XYZ(:,:,k) = single(sqrt(ptCloud.Location(:,:,1).^2 + ptCloud.Location(:,:,2).^2 + ptCloud.Location(:,:,3).^2));
    %Distances_RAW(:,:,k) = single(double(pcAttributes.Range));
    Distances_XYZ(:,:,k) = sqrt(ptCloud.Location(:,:,1).^2 + ptCloud.Location(:,:,2).^2 + ptCloud.Location(:,:,3).^2);
    Distances_RAW(:,:,k) = double(pcAttributes.Range);
    
    % On extrait la position X, Y, Z du pixel à chaque frame
    hist_X(k) = ptCloud.Location(point_L, point_C, 1);
    hist_Y(k) = ptCloud.Location(point_L, point_C, 2);
    hist_Z(k) = ptCloud.Location(point_L, point_C, 3);
end
disp('Extraction terminée avec succès !');

% Calcul de la Moyenne, Variance et Écart-Type point par point
Matrice_Moyenne_XYZ   = mean(Distances_XYZ, 3, 'omitnan');
Matrice_Variance_XYZ  = var(Distances_XYZ, 0, 3, 'omitnan');
Matrice_EcartType_XYZ = std(Distances_XYZ, 0, 3, 'omitnan');

Matrice_Moyenne_RAW   = mean(Distances_RAW, 3, 'omitnan');
Matrice_Variance_RAW  = var(Distances_RAW, 0, 3, 'omitnan');
Matrice_EcartType_RAW = std(Distances_RAW, 0, 3, 'omitnan');

% On extrait l'historique de la distance de notre pixel
historique_XYZ = squeeze(Distances_XYZ(point_L, point_C, :));
historique_RAW = squeeze(Distances_RAW(point_L, point_C, :));

% Enlève les zéros (On s'assure de garder les mêmes frames valides pour xyz
% et rho brute
valides = (historique_XYZ > 0) & (historique_RAW > 0);
historique_XYZ = historique_XYZ(valides); 
historique_RAW = historique_RAW(valides);
hist_X = hist_X(valides);
hist_Y = hist_Y(valides);
hist_Z = hist_Z(valides);

% Calcul des coordonnées moyennes pour l'affichage sur les histogrammes
mean_X = mean(hist_X); mean_Y = mean(hist_Y); mean_Z = mean(hist_Z);


% AFFICHAGE 1 : COMPARAISON DES DEUX HISTOGRAMMES
figure('Name', 'Comparaison des Histogrammes (XYZ vs RAW)', 'Position', [100, 100, 1000, 500]);

% Histogramme 1 distance Radiale xyz
subplot(1, 2, 1);
histfit(historique_XYZ,40);
title(['Méthode XYZ - Pixel (', num2str(point_L), ',', num2str(point_C), ')']);
xlabel('Distance mesurée (m)'); ylabel('Occurrences'); grid on;
moy_val_xyz = Matrice_Moyenne_XYZ(point_L, point_C);
var_val_xyz = Matrice_Variance_XYZ(point_L, point_C);
std_val_xyz = Matrice_EcartType_XYZ(point_L, point_C);
texte_stats_xyz = sprintf('Position : X=%.2f, Y=%.2f, Z=%.2f\n\nMoyenne : %.4f m\nVariance : %.2e\nEcart-type : %.4f m', mean_X, mean_Y, mean_Z, moy_val_xyz, var_val_xyz, std_val_xyz);
annotation('textbox', [0.13 0.72 0.20 0.15], 'String', texte_stats_xyz, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'FontWeight', 'bold', 'EdgeColor', 'k');
% Histogramme 2 données Brutes rho
subplot(1, 2, 2);
histfit(historique_RAW,40);
title(['Méthode RAW (\rho brut) - Pixel (', num2str(point_L), ',', num2str(point_C), ')']);
xlabel('Distance mesurée (m)'); ylabel('Occurrences'); grid on;
moy_val_raw = Matrice_Moyenne_RAW(point_L, point_C);
var_val_raw = Matrice_Variance_RAW(point_L, point_C);
std_val_raw = Matrice_EcartType_RAW(point_L, point_C);

texte_stats_raw = sprintf('Position : X=%.2f, Y=%.2f, Z=%.2f\n\nMoyenne : %.4f m\nVariance : %.2e\nEcart-type : %.4f m', mean_X, mean_Y, mean_Z, moy_val_raw, var_val_raw, std_val_raw);
annotation('textbox', [0.57 0.72 0.20 0.15], 'String', texte_stats_raw, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'FontWeight', 'bold', 'EdgeColor', 'k');
% BOÎTE À MOUSTACHES (BOXPLOT XYZ vs RAW)

figure('Name', 'Dispersion des mesures (Boxplot)', 'Position', [150, 150, 600, 500]);

% On regroupe les deux historiques dans un tableau à deux colonnes
donnees_boxplot = [historique_XYZ, historique_RAW];

% Création de la boîte à moustaches
boxplot(donnees_boxplot, 'Labels', {'Méthode 1 : XYZ', 'Méthode 2 : Brute (\rho)'});
title(['Comparaison de la dispersion - Pixel (', num2str(point_L), ',', num2str(point_C), ')']);
ylabel('Distance mesurée (m)');
grid on;


%  AFFICHAGE 3Ddu nuage de point 
figure('Name', 'Preuve visuelle de la cible');
pcshow(ptCloud_Visu); 
hold on;
x_cible = ptCloud_Visu.Location(point_L, point_C, 1);
y_cible = ptCloud_Visu.Location(point_L, point_C, 2);
z_cible = ptCloud_Visu.Location(point_L, point_C, 3);
plot3(x_cible, y_cible, z_cible, 'r*', 'MarkerSize', 10, 'LineWidth', 5); 
title(['Pixel test (', num2str(point_L), ',', num2str(point_C), ') sur le nuage 3D']);
grid on;
hold off;

disp('--- ANALYSE COMPARATIVE TERMINÉE ---');