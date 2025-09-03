function isFake = isFakeImage(img)
    % Load the template image of a real 100-rupee note
    template = imread('real_100_rupee_template.jpg');
    
    % Convert both images to grayscale
    imgGray = rgb2gray(img);
    templateGray = rgb2gray(template);
    
    % Detect SURF features
    pointsImg = detectSURFFeatures(imgGray);
    pointsTemplate = detectSURFFeatures(templateGray);
    
    % Extract features
    [featuresImg, validPointsImg] = extractFeatures(imgGray, pointsImg);
    [featuresTemplate, validPointsTemplate] = extractFeatures(templateGray, pointsTemplate);
    
    % Match features
    indexPairs = matchFeatures(featuresImg, featuresTemplate);
    
    % Retrieve locations of matched points
    matchedPointsImg = validPointsImg(indexPairs(:, 1), :);
    matchedPointsTemplate = validPointsTemplate(indexPairs(:, 2), :);
    
    % Estimate geometric transform between matched points
    try
        [tform, inlierIdx] = estimateGeometricTransform2D(matchedPointsTemplate, matchedPointsImg, 'similarity');
        numInliers = sum(inlierIdx);
    catch
        numInliers = 0; % If estimation fails, consider it as no match
    end
    
    % Set a threshold for the number of inliers
    threshold = 50;  % Adjust this threshold based on your tests
    
    % If the number of inliers is above the threshold, it's real
    isFake = numInliers < threshold;
end
