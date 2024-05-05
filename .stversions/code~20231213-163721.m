trainingImagesDirectory = 'images-unresized';

imds = imageDatastore(trainingImagesDirectory, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
targets = dummyvar(imds.Labels);
targets = targets';

numImages = numel(imds.Files);
imgSize = [256, 256];  % Adjust this based on the size of your images
numChannels = 3;  % Adjust this based on the number of channels in your images
inputs = zeros(prod(imgSize) * numChannels, numImages);
% Y = zeros(3, numImages);  % Adjust numClasses based on your problem

for i = 1:numImages
    disp([i " of " numImages])

    % Read an image
    img = readimage(imds, i);

    % Crop to object in image
    img = colorCropping(img);
    img = img{1};

    % Resize the image
    img = imresize(img, imgSize);

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

save('trainednetwork.mat', 'net');








