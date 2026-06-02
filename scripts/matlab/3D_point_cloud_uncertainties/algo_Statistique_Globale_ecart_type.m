clear;
clc;
close all;

pcapFile = 'aquisition2.pcap';
jsonFile = 'aquisition2.json';

disp('--- DÉMARRAGE DE L''ANALYSE : FACE AVANT UNIQUEMENT ---');


% 1. COMPTAGE ET PRÉPARATION DES FRAMES

reader_rapide = ousterFileReader(pcapFile, jsonFile);
total_frames = 0;
while hasFrame(reader_rapide)
    readFrame(reader_rapide);
    total_frames = total_frames + 1;
end
frame_ignorer = 2; 
frame_debut = frame_ignorer + 1;
frame_fin = total_frames - frame_ignorer;
nb_frames_utiles = frame_fin - frame_debut + 1; 


% CRÉATION DES MATRICES D'ANGLES Pures pour tetha phy


reader = ousterFileReader(pcapFile, jsonFile);
for i = 1:(frame_debut - 1)
    readFrame(reader); 
end
[ptCloud, ~] = readFrame(reader); 

%coordoner pour visualiser la frame 1
X_init = ptCloud.Location(:,:,1);
Y_init = ptCloud.Location(:,:,2);
Z_init = ptCloud.Location(:,:,3);

% On récupère la vraie taille de la matrice du capteur ex: 128 x 1024
[LIGNES, COLONNES, ~] = size(ptCloud.Location); 

% Axe Horizontal (Theta)
% 360 degrés répartis sur le nombre de colonnes (1024)
ref_theta = 360 / COLONNES; 
% On crée une ligne qui va de 0° à 359.6° avec un pas de ref_theta
vecteur_theta = linspace(0, 360 - ref_theta, COLONNES); 

%  (Phi) 
vecteur_phi = linspace(21.43, -21.5, LIGNES); 


%Création des matrices phi et tetha (128x1024)
% repmat va dupliquer notre ligne/colonne pour remplir tout le "mur" de pixels
Matrice_Theta = repmat(vecteur_theta, LIGNES, 1); 
Matrice_Phi   = repmat(vecteur_phi', 1, COLONNES); 


% 3. MASQUE FACE AVANT 
masque_avant = (Matrice_Theta >= 240) & (Matrice_Theta <= 300);
nb_pixels_avant = sum(masque_avant(:)); 

Dist_XYZ_Avant = zeros(nb_pixels_avant, nb_frames_utiles, 'single');
Dist_RAW_Avant = zeros(nb_pixels_avant, nb_frames_utiles, 'single');


% 4. LECTURE OPTIMISÉE ET FILTRAGE

reader = ousterFileReader(pcapFile, jsonFile);
for i = 1:(frame_debut - 1)
    readFrame(reader); 
end

disp('-> Extraction des données en cours...');
for k = 1:nb_frames_utiles
    [ptCloud, pcAttributes] = readFrame(reader);
    
    X = ptCloud.Location(:,:,1);
    Y = ptCloud.Location(:,:,2);
    Z = ptCloud.Location(:,:,3);
    Rho_XYZ = sqrt(X.^2 + Y.^2 + Z.^2);
    Rho_RAW = single(pcAttributes.Range);
    
    Rho_XYZ(Rho_XYZ == 0) = NaN;
    Rho_RAW(Rho_RAW == 0) = NaN;
    
    Dist_XYZ_Avant(:, k) = Rho_XYZ(masque_avant);
    Dist_RAW_Avant(:, k) = Rho_RAW(masque_avant);
end


% 5. CALCUL DES STATISTIQUES

Moy_XYZ_1D = mean(Dist_XYZ_Avant, 2, 'omitnan');
Std_XYZ_1D = std(Dist_XYZ_Avant, 0, 2, 'omitnan');
Moy_RAW_1D = mean(Dist_RAW_Avant, 2, 'omitnan');
Std_RAW_1D = std(Dist_RAW_Avant, 0, 2, 'omitnan');

clear Dist_XYZ_Avant Dist_RAW_Avant X Y Z ptCloud pcAttributes reader reader_rapide;




% 6. AFFICHAGE déco

figure('Name', 'Bruit du capteur (Face Avant uniquement)', 'Position', [100, 100, 1200, 500]);

% Graphique 1 : XYZ
subplot(1, 2, 1);
plot(Moy_XYZ_1D, Std_XYZ_1D, '.', 'Color', [0 0.4470 0.7410], 'MarkerSize', 2); 
title('Méthode 1 : XYZ (Face Avant)');
xlabel('Distance moyenne mesurée (m)');
ylabel('Erreur / Écart-type (m)');
grid on; 
xlim([0.5 8]); ylim([0 0.05]);
legend('Bruit par pixel', 'Location', 'NorthEast');

% Graphique 2 : RAW
subplot(1, 2, 2);
plot(Moy_RAW_1D, Std_RAW_1D, '.', 'Color', [0.8500 0.3250 0.0980], 'MarkerSize', 2); 
title('Méthode 2 : Données Brutes \rho (Face Avant)');
xlabel('Distance moyenne mesurée (m)');
ylabel('Erreur / Écart-type (m)');
grid on; 
xlim([0.5 8]); ylim([0 0.05]);
legend('Bruit par pixel', 'Location', 'NorthEast');
% 7. on voit la premier frame pour savoire est ce que on est en face ou pas
X_verif = X_init(masque_avant);
Y_verif = Y_init(masque_avant);
Z_verif = Z_init(masque_avant);

figure('Name', 'Vérification de la coupe');
ptCloud_Avant = pointCloud([X_verif, Y_verif, Z_verif]);
pcshow(ptCloud_Avant);
title('Vue 3D des pixels analysés (Face Avant)');
xlabel('X'); ylabel('Y'); zlabel('Z');

disp('--- ANALYSE TERMINÉE ---');