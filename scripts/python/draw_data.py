import os
from ouster import client, pcap

# ====== CONFIGURATION DES CHEMINS ======
# Remplacez par les chemins vers vos propres fichiers
json_path = "meta_os1_128.json"
pcap_path = "data_os1_128.pcap"

if not os.path.exists(json_path) or not os.path.exists(pcap_path):
    print("Erreur : Veuillez vérifier les chemins du fichier JSON et PCAP.")
    exit(1)

print("Chargement des métadonnées et initialisation du flux PCAP...")

# 1. Chargement des métadonnées du capteur (le fichier JSON)
with open(json_path, 'r') as f:
    metadata = client.SensorInfo(f.read())

# 2. Initialisation de la source PCAP
# Le paramètre 'rate' à 0 permet de lire le fichier le plus vite possible
pcap_source = pcap.Pcap(pcap_path, metadata, rate=0)

# 3. Création du générateur de scans (regroupe les paquets en images/scans complets)
scans = client.Scans(pcap_source)

# 4. Configuration du calculateur de coordonnées 3D (Lookup Table XYZ)
xyz_lut = client.XYZLut(metadata)

print(f"Début de la lecture du fichier. Capteur détecté : {metadata.prod_line} ({metadata.mode})")

# Boucle de lecture des scans du LiDAR
try:
    for idx, scan in enumerate(scans):
        # On extrait les matrices de données brutes pour ce scan
        # 'RANGE' = Distance, 'REFLECTIVITY' / 'SIGNAL' = Intensité du retour
        range_field = scan.field(client.ChanField.RANGE)
        intensity_field = scan.field(client.ChanField.REFLECTIVITY)
        
        # Calcul des coordonnées cartésiennes réelles (X, Y, Z) en mètres
        xyz_points = xyz_lut(scan)
        
        # Restructuration pour manipulation facile (par exemple avec numpy si besoin)
        # xyz_points est un tableau de forme (Hauteur, Largeur, 3) -> (128, Largeur, 3)
        num_points = xyz_points.shape[0] * xyz_points.shape[1]
        
        print(f"--- Scan #{idx:04d} ---")
        print(f"Nombre de lignes (Canaux) : {xyz_points.shape[0]} (OS1-128)")
        print(f"Nombre total de points dans ce scan : {num_points}")
        
        # Exemple d'accès aux coordonnées du tout premier point valide trouvé
        # (On cherche un point dont la distance 'range' n'est pas nulle)
        valides = range_field > 0
        if valides.any():
            # Récupération des indices du premier point valide
            row, col = np.argwhere(valides)[0] if 'np' in locals() else (64, 0) # Valeur arbitraire par défaut
            
            x = xyz_points[row, col, 0]
            y = xyz_points[row, col, 1]
            z = xyz_points[row, col, 2]
            intensity = intensity_field[row, col]
            
            print(f"Exemple de point valide au pixel [{row}, {col}] :")
            print(f"  X: {x:.3f}m, Y: {y:.3f}m, Z: {z:.3f}m | Intensité: {intensity}")
            
        # Limite de lecture pour l'exemple (enlever ou commenter pour lire tout le fichier)
        if idx >= 5:
            print("\nLecture interrompue après 5 scans pour l'exemple.")
            break

except KeyboardInterrupt:
    print("\nLecture interrompue par l'utilisateur.")
finally:
    pcap_source.close()
    print("Fichier PCAP fermé proprement.")