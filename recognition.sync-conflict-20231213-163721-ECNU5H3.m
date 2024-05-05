load('trainednetwork.mat', 'net')

%clf
%vid = videoinput('macvideo',2);
%vid.ReturnedColorspace = 'rgb';
%start(vid);
%im=getsnapshot(vid);
 
%imshow(im);
%delete(vid);

image = imread('sample-input-images-new/IMG_20231211_153411.jpg');

croppedObjects = colorCropping(image);

croppedObjectCount = length(croppedObjects);
imgSubplotSize = ceil(sqrt(croppedObjectCount));

labelList = unique(imds.Labels);

% settings for importing csv file
opts = delimitedTextImportOptions("NumVariables", 8);
% Specify range and delimiter
opts.DataLines = [2, Inf];
% Specify column names and types
opts.VariableNames = ["name", "calories", "fats", "protein", "carbohydrates", "sugar", "fiber", "potassium"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double"];
% Import the dataimgVector
nutritiondata = readtable("nutrition-data.csv", opts, 'ReadRowNames', true);

pictureNutritionValues = table('Size', [1 7], ...
    'VariableNames', trimdata(opts.VariableNames,7,Side="leading"), 'VariableTypes', trimdata(opts.VariableTypes, 7, Side="leading"));

figure('Position', [100 100 1600 900]);

for i = 1:croppedObjectCount
    I = croppedObjects{i};
    %imgSize = [256, 256];  % Adjust this based on the size of your images
    %numChannels = 3;  % Adjust this based on the number of channels in your images
    %input = zeros(prod(imgSize) * numChannels, 1);
    %input(:, 1) = imgVector(:);
    
    % Flatten and preprocess the image into a vector
    %imageVector = double(grayImage(:));  % Ensure the data type is compatible with the network
    %imageMatrix = reshape(inputImage, [], numChannels);
    %imageVector = imageMatrix(:);
    
    % Reshape or preprocess the input if needed
    % Make sure to use the correct input size and data type
    %output = net(imageVector);

    %I = imresize(I, [256 256]);
    %imshow(I);
    imageVector = double(I(:));

    output = sim(net, imageVector);

    [confidence, predictedClass] = max(output);

    subplot(imgSubplotSize, imgSubplotSize+1, i);
    imshow(croppedObjects{i});

    objectNutritionValues = [
        nutritiondata(predictedClass, "calories") nutritiondata(predictedClass, "fats") nutritiondata(predictedClass, "protein") ...
        nutritiondata(predictedClass, "carbohydrates") nutritiondata(predictedClass, "sugar") nutritiondata(predictedClass, "fiber") ...
        nutritiondata(predictedClass, "potassium")
    ];

    pictureNutritionValues = sum(pictureNutritionValues + objectNutritionValues);

    objectNutritionLabels = sprintf('Calories: %d kcal\nFat: %d g\nProtein: %d g\nCarbohydrates: %d g\nSugar: %d g\nFiber: %d g\nPotassium: %d mg', ...
        objectNutritionValues.Variables);

    % title([sprintf('Prediction: %s (%2.1f%%)', labelList(predictedClass), confidence*100)]);
    title([sprintf('Is this: %s?', labelList(predictedClass))]);
    xlabel(objectNutritionLabels);
    %ylabel(round(output*100, 3));
end

pictureNutritionValuesPlot = [
    pictureNutritionValues(:, "calories") pictureNutritionValues(:, "fats") pictureNutritionValues(:, "protein") ...
    pictureNutritionValues(:, "carbohydrates") pictureNutritionValues(:, "sugar") pictureNutritionValues(:, "fiber") ...
    pictureNutritionValues(:, "potassium")
];

pictureNutritionLabel = sprintf(...
    'Total nutritional value of all food in picture\n===\nCalories: %d kcal\nFat: %d g\nProtein: %d g\nCarbohydrates: %d g\nSugar: %d g\nFiber: %d g\nPotassium: %d mg', ...
    pictureNutritionValuesPlot.Variables);

pictureNutritionLabelPlot = subplot(imgSubplotSize, imgSubplotSize+1, i+1);
p = plot(1);
p.Visible = 'off';
uicontrol('style','text');
axis off;
text(0, 0.5, pictureNutritionLabel, 'Parent', pictureNutritionLabelPlot);



