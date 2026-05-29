function ptCloud_corrige = transformation_world_frame(ptCloud_in, imu)
    %% TRANSFORMATION_WORLD_FRAME Compense l'inclinaison de l'ASV via les données IMU
    % 
    % Authors: LISIC Laboratory (UR 4491) / ULCO 
    %
    % Description :
    %   Calcule l'attitude (Roulis/Tangage) à partir de l'accéléromètre,
    %   combine le changement de repère (LiDAR <-> IMU) et la rotation de 
    %   correction en une seule matrice homogène, puis applique la 
    %   transformation en une unique passe pour maximiser les performances.

    %% 1. EXTRACTION DE LA COMPOSANTE ACCÉLÉROMÉTRIQUE
    if isstruct(imu) || istable(imu)
        accel_data = imu.AccelerometerReadings{:, :};
        ax = mean(accel_data(:,1));
        ay = mean(accel_data(:,2));
        az = mean(accel_data(:,3));
    else
        % Mode temps réel / Vecteur direct [ax, ay, az]
        ax = imu(1);
        ay = imu(2);
        az = imu(3);
    end

    %% 2. ESTIMATION DE L'ATTITUDE (ROLL / PITCH) & MATRICE DE ROTATION
    roll  = atan2(ay, az);
    pitch = atan2(-ax, sqrt(ay^2 + az^2));
    
    % Matrices de rotation élémentaires
    Rx = [1,         0,          0;
          0,  cos(roll), -sin(roll);
          0,  sin(roll),  cos(roll)];
          
    Ry = [cos(pitch), 0, sin(pitch);
          0,          1,          0;
         -sin(pitch), 0, cos(pitch)];
         
    % Rotation inverse pour corriger l'inclinaison de la plateforme maritime
    R_correction = (Ry * Rx)';

    %% 3. ANALYSE DES BRAS DE LEVIER GÉOMÉTRIQUES (Vecteurs en Mètres)
    t_imu_sensor   = [0.006253, -0.011775, 0.007645] / 1000;
    t_lidar_sensor = [0, 0, 36.18] / 1000;
    
    % Décalage du repère LiDAR vers le repère IMU
    t_lidar_to_imu = t_imu_sensor - t_lidar_sensor;

    %% 4. COMPOSITION DE LA TRANSFORMATION GÉOMÉTRIQUE UNIQUE
    % Au lieu de faire 3 transformations successives sur le nuage de points,
    % on combine mathématiquement T1, T2 et T3 en une seule matrice homogène.
    %
    % Formule mathématique globale : P_corrigé = R_corr * (P_brut - t) + t
    %                                         = R_corr * P_brut + (t - R_corr * t)
    
    translation_combinee = t_lidar_to_imu - (R_correction * t_lidar_to_imu')';
    
    % Création de l'objet de transformation rigide global
    tform_globale = rigidtform3d(R_correction, translation_combinee);

    %% 5. APPLICATION UNIQUE SUR LE NUAGE DE POINTS
    % Gain de performance majeur : réduction drastique des allocations mémoire.
    ptCloud_corrige = pctransform(ptCloud_in, tform_globale);
end