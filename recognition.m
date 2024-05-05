load('trainednetwork.mat', 'net') % load our neural network

% used for taking a picture live from camera (not during live demo)
% clf
% vid = videoinput('macvideo',2);
% vid.ReturnedColorspace = 'rgb';
% start(vid);
% image=getsnapshot(vid);
% 
% imshow(im);
% delete(vid);

% load image from our sample images directory
image = imread('sample-input-images-new\IMG_20231211_153344.jpg');

% get individual pieces of food saved in a vector
croppedObjects = colorCropping(image);

croppedObjectCount = length(croppedObjects);
imgSubplotSize = ceil(sqrt(croppedObjectCount));

load('labelList.mat', 'labelList'); % load are labels list

% settings for importing csv file
opts = delimitedTextImportOptions("NumVariables", 8);
% specify range and delimiter
opts.DataLines = [2, Inf];
% column names and types
opts.VariableNames = ["name", "calories", "fats", "protein", "carbohydrates", "sugar", "fiber", "potassium"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double"];
% import the dataimgVector
nutritiondata = readtable("nutrition-data.csv", opts, 'ReadRowNames', true);

pictureNutritionValues = table('Size', [1 7], ...
    'VariableNames', trimdata(opts.VariableNames,7,Side="leading"), 'VariableTypes', trimdata(opts.VariableTypes, 7, Side="leading"));

figure('Position', [100 100 1600 900]);

for i = 1:croppedObjectCount
    I = croppedObjects{i};

    imageVector = double(I(:)); % transform into vector

    output = sim(net, imageVector); % classify with NN

    [confidence, predictedClass] = max(output); % get the class with highest confidence

    % plot
    subplot(imgSubplotSize, imgSubplotSize+1, i);
    imshow(croppedObjects{i});

    objectNutritionValues = [
        nutritiondata(predictedClass, "calories") nutritiondata(predictedClass, "fats") nutritiondata(predictedClass, "protein") ...
        nutritiondata(predictedClass, "carbohydrates") nutritiondata(predictedClass, "sugar") nutritiondata(predictedClass, "fiber") ...
        nutritiondata(predictedClass, "potassium")
    ];

    % sum of nutritional values
    pictureNutritionValues = sum(pictureNutritionValues + objectNutritionValues);

    objectNutritionLabels = sprintf('Calories: %d kcal\nFat: %d g\nProtein: %d g\nCarbohydrates: %d g\nSugar: %d g\nFiber: %d g\nPotassium: %d mg', ...
        objectNutritionValues.Variables);

    title([sprintf('Is this: %s?', labelList(predictedClass))]);
    xlabel(objectNutritionLabels);
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



