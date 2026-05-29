function [candidats, boites] = segmentation_floating_objects(rho_sans_sol, ptCloud_sans_sol)
    %% SEGMENTATION_FLOATING_OBJECTS Détection et détourage d'objets sur image de portée
    %
    % Authors: LISIC Laboratory (UR 4491) / ULCO 
    %
    % Description :
    %   Segmente les objets flottants en détectant les discontinus (sauts de portée)
    %   via un seuillage adaptatif horizontal et vertical. Génère les centroïdes
    %   et les boîtes englobantes (Bounding Boxes) 3D des candidats valides.

    [lignes, cols] = size(rho_sans_sol);
    
    % Allocation statique des matrices de frontières (Gain mémoire majeur)
    frontiere_horiz = false(lignes, cols-1);
    frontiere_vert  = false(lignes-1, cols);
    
    seuil_initial    = 0.05; 
    precision_ouster = 0.03;
    tol_bruit        = 1.5; % Facteur multiplicateur pour tolérer le bruit de l'eau

    %% 1. BALAYAGE HORIZONTAL OPTIMISÉ (Analyse des lignes)
    for i = 1:lignes
        seuil_actuel = seuil_initial;
        count = 0;
        somme_sauts = 0; % Évite l'allocation dynamique de tableaux []
        
        for j = 2:cols
            val_actuelle = rho_sans_sol(i, j);
            val_precedente = rho_sans_sol(i, j-1);
            
            if val_actuelle > 0 && val_precedente > 0
                saut = abs(val_actuelle - val_precedente);
                
                if count == 0
                    condition = saut > seuil_actuel;
                else
                    condition = saut > (tol_bruit * seuil_actuel); 
                end
                
                if condition
                    frontiere_horiz(i, j-1) = true;
                    seuil_actuel = seuil_initial; 
                    count = 0;
                    somme_sauts = 0;
                else
                    % Mise à jour glissante de la moyenne sans réallocation mémoire
                    count = count + 1;
                    somme_sauts = somme_sauts + saut;
                    seuil_actuel = max(precision_ouster, somme_sauts / count);
                end
            end
        end
    end
    
    %% 2. BALAYAGE VERTICAL OPTIMISÉ (Analyse des colonnes)
    for j = 1:cols
        seuil_actuel = seuil_initial;
        count = 0;
        somme_sauts = 0;
        
        for i = 2:lignes
            val_actuelle = rho_sans_sol(i, j);
            val_precedente = rho_sans_sol(i-1, j);
            
            if val_actuelle > 0 && val_precedente > 0
                saut = abs(val_actuelle - val_precedente);
                
                if count == 0
                    condition = saut > seuil_actuel;
                else
                    condition = saut > (tol_bruit * seuil_actuel); 
                end
                
                if condition  
                    frontiere_vert(i-1, j) = true;
                    seuil_actuel = seuil_initial;
                    count = 0;
                    somme_sauts = 0;
                else
                    count = count + 1;
                    somme_sauts = somme_sauts + saut;
                    seuil_actuel = max(precision_ouster, somme_sauts / count);
                end
            end
        end
    end
     
    %% 3. APPLICATION DES FRONTIÈRES ("COUP DE CISEAUX")
    image_objets = rho_sans_sol > 0;
    
    image_objets(:, 1:end-1) = image_objets(:, 1:end-1) & ~frontiere_horiz;
    image_objets(:, 2:end)   = image_objets(:, 2:end)   & ~frontiere_horiz;
    image_objets(1:end-1, :) = image_objets(1:end-1, :) & ~frontiere_vert;
    image_objets(2:end, :)   = image_objets(2:end, :)   & ~frontiere_vert;
 
    % Étiquetage des composantes connexes (Voisinage à 4 pixels)
    [labels_2D, nb_regions] = bwlabel(image_objets, 4);
    
    %% 4. EXTRACTION DES COORDONNÉES 3D & FILTRAGE GÉOMÉTRIQUE
    X = ptCloud_sans_sol.Location(:, :, 1);
    Y = ptCloud_sans_sol.Location(:, :, 2);
    Z = ptCloud_sans_sol.Location(:, :, 3);
    
    % Pré-allocation des structures de sortie
    candidats = struct('centre', {}).';
    boites    = [];
    
    for k = 1 : nb_regions
        masque_k = (labels_2D == k);
        X_k = X(masque_k); Y_k = Y(masque_k); Z_k = Z(masque_k);
        
        % Filtrage des valeurs invalides (NaN)
        ok = ~isnan(X_k) & ~isnan(Y_k) & ~isnan(Z_k);
        X_k = X_k(ok); Y_k = Y_k(ok); Z_k = Z_k(ok);
        
        % Critère 1 : Filtre de densité (Élimination du bruit isolé / clusters trop épars)
        if length(X_k) < 5
            continue;
        end
        
        % Calcul des dimensions de la boîte englobante (AABB alignée sur les axes)
        larg = max(X_k) - min(X_k);
        prof = max(Y_k) - min(Y_k);
        haut = max(Z_k) - min(Z_k);
        
        % Critère 2 : Filtre de taille maximale (Élimination des infrastructures/berges)
        if larg > 3.0 || prof > 3.0
            continue;
        end
        
        % Critère 3 : Filtre de hauteur minimale (Élimination des résidus de clapotis/surface de l'eau)
        if haut < 0.1
            continue;
        end
        
        % Calcul du centroïde géométrique
        x_centre = min(X_k) + (larg / 2);
        y_centre = min(Y_k) + (prof / 2);
        z_centre = min(Z_k) + (haut / 2);
        
        % Enregistrement du candidat
        candidats(end+1).centre = [x_centre, y_centre, z_centre]; %#ok<AGROW>
        
        % Format MATLAB standard pour Cuboid : [x, y, z, x_size, y_size, z_size, roll, pitch, yaw]
        boites = [boites; x_centre, y_centre, z_centre, larg, prof, haut, 0, 0, 0]; %#ok<AGROW>
    end
end