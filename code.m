% specify the name of the directory with our training dataset
trainingImagesDirectory = 'images-unresized';

imds = imageDatastore(trainingImagesDirectory, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
targets = dummyvar(imds.Labels);
targets = targets'; % transpose it for NN

numImages = numel(imds.Files);
imgSize = [256, 256]; % small enough to not too much space
numChannels = 3; % RGB images
inputs = zeros(prod(imgSize) * numChannels, numImages); % initialize inputs

for i = 1:numImages
    % disp([i " of " numImages])
    img = readimage(imds, i);

    img = colorCropping(img); % use colorCropping function on each image before training
    img = img{1};
    img = imresize(img, imgSize);
    imgVector = reshape(img, [], numChannels); % transform image into a vector
   
    inputs(:, i) = imgVector(:); % add it into inputs matrix
end

net = patternnet(25); % 25 hidden layers for higher accuracy
net = train(net, inputs, targets);

save('trainednetwork.mat', 'net'); % save NN into a file

labelList = unique(imds.Labels);
save('labelList.mat', 'labelList');







