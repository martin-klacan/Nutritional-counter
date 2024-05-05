load('trainednetwork.mat', 'net')

image = imread('sample-input-images-new/IMG_20231211_153444.jpg');

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

    objectNutritionLabels = sprintf('Calories: %d kcal\n Fat: %d g\n Protein: %d g\n Carbohydrates: %d g\n Sugar: %d g\n Fiber: %d g\n Potassium: %d mg', ...
        objectNutritionValues.Variables);

    title([sprintf('Prediction: %s (%2.1f%%)', labelList(predictedClass), confidence*100)]);
    xlabel(objectNutritionLabels);
    %ylabel(round(output*100, 3));
end

disp('Total nutritional value of all food in picture:')
disp(pictureNutritionValues)

pictureNutritionValuesPlot = [
    pictureNutritionValues(:, "calories") pictureNutritionValues(:, "fats") pictureNutritionValues(:, "protein") ...
    pictureNutritionValues(:, "carbohydrates") pictureNutritionValues(:, "sugar") pictureNutritionValues(:, "fiber") ...
    pictureNutritionValues(:, "potassium")
];

pictureNutritionLabel = sprintf('Total nutritional value of all food in picture\n===\nCalories: %d kcal\n Fat: %d g\n Protein: %d g\n Carbohydrates: %d g\n Sugar: %d g\n Fiber: %d g\n Potassium: %d mg', ...
    pictureNutritionValuesPlot.Variables);

totalImageSubplot = imgSubplotSize*(imgSubplotSize+1)-1;
pictureNutritionLabelPlot = subplot(imgSubplotSize, imgSubplotSize+1, totalImageSubplot);
p = plot(1);
p.Visible = 'off';
uicontrol('style','text');
axis off;
text(0, 0, pictureNutritionLabel, 'Parent', pictureNutritionLabelPlot);



