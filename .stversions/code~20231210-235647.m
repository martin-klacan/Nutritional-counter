imds = imageDatastore('Images', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
targets = dummyvar(imds.Labels);
targets = targets';

%inputs = augmentedImageDatastore([227 227], imds);
% Read images from the imageDatastore

numImages = numel(imds.Files);
imgSize = [256, 256];  % Adjust this based on the size of your images
numChannels = 3;  % Adjust this based on the number of channels in your images
inputs = zeros(prod(imgSize) * numChannels, numImages);
% Y = zeros(3, numImages);  % Adjust numClasses based on your problem

for i = 1:numImages
    % Read an image
    img = readimage(imds, i);
    
    % Resize the image if needed
    %img = imresize(img, imgSize);

    % Flatten the image into a column vector
    imgVector = reshape(img, [], numChannels);
    
    % Store the flattened image in the X matrix
    inputs(:, i) = imgVector(:);
    
    % Assign the corresponding label to Y
    % Replace this with your label assignment logic
    % Y(:, i) = categorical(imds.Labels(i) == categories(imds.Labels));
end

net = patternnet(25);
net = train(net, inputs, targets);








