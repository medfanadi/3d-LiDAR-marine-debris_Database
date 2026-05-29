%% ========================================================================
%  MARINE PERCEPTION SYSTEMS: AUTONOMOUS DETECTION WITHOUT GROUND EXTRACTION
% ========================================================================
%  Authors: LISIC Laboratory (UR 4491) / ULCO 
%  Lead Investigator: Mohamed FNADI
%  
%  Description: 3D-LiDAR data processing pipeline optimized for 
%               floating marine debris detection, segmentation, and bounding 
%               box estimation on Autonomous Surface Vehicles (ASVs).
% ========================================================================

clear; clc; close all;

fprintf('\n========================================================\n');
fprintf('  MARINE PERCEPTION: FLOATING DEBRIS DETECTION ENGINE  \n');
fprintf('========================================================\n\n');

%% 1. DATA SOURCE SELECTION
% Select active acquisition stream (Uncomment desired sequence)
% pcapFile = '4_objets_version2.pcap';     jsonFile = '4_objets_version2.json';
pcapFile = 'trois_objets_version2.pcap'; jsonFile = 'trois_objets_version2.json';
% pcapFile = 'un_objet_dinamique.pcap';   jsonFile = 'un_objet_dinamique.json';
% pcapFile = 'un_objet_version3.pcap';     jsonFile = 'un_objet_version3.json';
% pcapFile = 'trois_objets_dans_eau.pcap'; jsonFile = 'trois_objets_dans_eau.json';
% pcapFile = '4_objets.pcap';             jsonFile = '4_objets.json';
% pcapFile = 'deux_objets_dans_eau.pcap';  jsonFile = 'deux_objets_dans_eau.json';
% pcapFile = 'un_objet_version2.pcap';     jsonFile = 'un_objet_version2.json';

%% 2. PARSE HARDWARE CONFIGURATION & BEAM INTRINSICS
fprintf('Initializing Ouster OS1-128 configuration parser...\n');
configData = jsondecode(fileread(jsonFile));

if isfield(configData, 'data_format')
    numCols     = configData.data_format.columns_per_frame;
    numRows     = configData.data_format.pixels_per_column;
    beamAngles  = configData.beam_altitude_angles;
elseif isfield(configData, 'lidar_data_format')
    numCols     = configData.lidar_data_format.columns_per_frame;
    numRows     = configData.lidar_data_format.pixels_per_column;
    beamAngles  = configData.beam_intrinsics.beam_altitude_angles;
else
    error('Execution Error: Unrecognized JSON metadata schema.');
end

% Compute raw azimuthal spatial resolution
rawAzimuthAngles = (0 : numCols-1) * (360 / numCols);

%% 3. REGION OF INTEREST (ROI) CONFIGURATION
% Configure forward-facing perception arc (e.g., situational awareness ahead of ASV bow)
semiAngleWidth = 70;   % Operational lateral field-of-view sweep bounds (degrees)
forwardHeading = 180;  % Primary tracking boresight reference vector

roiMask        = abs(rawAzimuthAngles - forwardHeading) <= semiAngleWidth;
roiColIndices  = find(roiMask);

%% 4. SENSOR LINKAGE & GRAPHICS INITIALIZATION
% Connect interface wrapper to the hardware capture data stream
pcapReader   = ousterFileReader(pcapFile, jsonFile);
imuTelemetry = readIMU(pcapReader);
totalFrames  = pcapReader.NumberOfFrames;

% Initialize immersive 3D visualization player (50-meter operating envelope)
spatialBounds = [-50 50; -50 50; -5 5];
cloudViewer   = pcplayer(spatialBounds(1,:), spatialBounds(2,:), spatialBounds(3,:));
title(cloudViewer.Axes, 'Real-Time Marine Object Tracking Engine', 'Color', [1 1 1]);

%% 5. DEPLOYMENT CORE COMPUTATION LOOP
fprintf('Beginning streaming telemetry playback. Processing %d frames...\n\n', totalFrames);
activeFrameCounter = 0;

for frameIdx = 1 : totalFrames
    if ~isOpen(cloudViewer)
        break; 
    end
    activeFrameCounter = activeFrameCounter + 1;
    
    % ---------------------------------------------------------------------
    % Step 5.1: Ingestion & Pose Synchronization via IMU Telemetry
    % ---------------------------------------------------------------------
    [ptCloudRaw, sampleAttributes] = readFrame(pcapReader, frameIdx);
    rawRanges = double(sampleAttributes.Range);
    
    % Transform coordinates from body-frame coordinates into a stable spatial frame
    ptCloudAligned = transformation_world_frame(ptCloudRaw, imuTelemetry);
    
    % ---------------------------------------------------------------------
    % Step 5.2: Spatial Isolation (Applying Dynamic Forward ROI)
    % ---------------------------------------------------------------------
    xAligned = ptCloudAligned.Location(:, roiColIndices, 1);
    yAligned = ptCloudAligned.Location(:, roiColIndices, 2);
    zAligned = ptCloudAligned.Location(:, roiColIndices, 3);
    
    workingRoiRanges = rawRanges(:, roiColIndices);
    roiStructuredMap = cat(3, xAligned, yAligned, zAligned);
    ptCloudRoiOnly   = pointCloud(roiStructuredMap);
    
    % ---------------------------------------------------------------------
    % Step 5.3: Raw Range Image Target Clustering & Segmentation
    % ---------------------------------------------------------------------
    [targetCandidates, boundingBoxes] = segmentation_floating_objects(workingRoiRanges, ptCloudRoiOnly);
    numDetectedObjects = numel(targetCandidates);
    
    fprintf('[FRAME %04d] - Objects Identified: %d\n', activeFrameCounter, numDetectedObjects);
    
    % ---------------------------------------------------------------------
    % Step 5.4: Rendering Optimization & Color Channel Layering
    % ---------------------------------------------------------------------
    ptCloudDisplay = ptCloudAligned;
    [canvasRows, canvasCols, ~] = size(ptCloudDisplay.Location);
    
    % Generate standard passive white rendering map for the ambient space matrix
    pointColors = ones(canvasRows, canvasCols, 3, 'uint8') * 255;
    
    xDisplay = ptCloudDisplay.Location(:,:,1);
    yDisplay = ptCloudDisplay.Location(:,:,2);
    zDisplay = ptCloudDisplay.Location(:,:,3);
    
    % Overlay target tracking masks directly onto coordinate spaces
    if ~isempty(boundingBoxes)
        for boxIdx = 1 : size(boundingBoxes, 1)
            currentBox = boundingBoxes(boxIdx, :);
            
            % Resolve cuboid boundary limits
            xMin = currentBox(1) - currentBox(4)/2; xMax = currentBox(1) + currentBox(4)/2;
            yMin = currentBox(2) - currentBox(5)/2; yMax = currentBox(2) + currentBox(5)/2;
            zMin = currentBox(3) - currentBox(6)/2; zMax = currentBox(3) + currentBox(6)/2;
            
            % Generate localized target identification masks
            targetInlierMask = (xDisplay >= xMin & xDisplay <= xMax) & ...
                               (yDisplay >= yMin & yDisplay <= yMax) & ...
                               (zDisplay >= zMin & zDisplay <= zMax);
            
            % Project deep blue coloring layers onto isolated candidate indexes
            rChannel = pointColors(:,:,1); gChannel = pointColors(:,:,2); bChannel = pointColors(:,:,3);
            rChannel(targetInlierMask) = 0; gChannel(targetInlierMask) = 0; bChannel(targetInlierMask) = 255;
            pointColors(:,:,1) = rChannel; pointColors(:,:,2) = gChannel; pointColors(:,:,3) = bChannel;
        end
    end
    ptCloudDisplay.Color = pointColors;
    
    % ---------------------------------------------------------------------
    % Step 5.5: Spatial Window Clamping & Boundary Optimization
    % ---------------------------------------------------------------------
    xFinal = ptCloudDisplay.Location(:,:,1);
    yFinal = ptCloudDisplay.Location(:,:,2);
    zFinal = ptCloudDisplay.Location(:,:,3);
    
    validIndices = find(xFinal >= spatialBounds(1,1) & xFinal <= spatialBounds(1,2) & ...
                        yFinal >= spatialBounds(2,1) & yFinal <= spatialBounds(2,2) & ...
                        zFinal >= spatialBounds(3,1) & zFinal <= spatialBounds(3,2));
                        
    ptCloudDisplay = select(ptCloudDisplay, validIndices);
    
    % ---------------------------------------------------------------------
    % Step 5.6: Render Graphics & Overlay Estimated Target Polygons
    % ---------------------------------------------------------------------
    view(cloudViewer, ptCloudDisplay);
    
    % Safely flush old graphic handles from the engine axes layout
    delete(findobj(cloudViewer.Axes, 'Type', 'Patch'));
    
    if ~isempty(boundingBoxes)
        vibrantGreenColors = repmat([0 1 0], size(boundingBoxes, 1), 1);
        showShape('cuboid', boundingBoxes, ...
                  'Parent', cloudViewer.Axes, ...
                  'Color', vibrantGreenColors, ...
                  'Opacity', 0.15, ...
                  'LineWidth', 1.0); % Increased width line weight for presentations
    end
    
    drawnow limitrate;
end

fprintf('\n========================================================\n');
fprintf('  Processing Completed. Active streaming session ended.\n');
fprintf('========================================================\n');