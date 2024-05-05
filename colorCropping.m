function [croppedObjects] = colorCropping(image)

% color range for our objects
lowerColor = [80, 75, 0];
upperColor = [255, 255, 100];

% binary mask with our color range
binaryMask = (image(:,:,1) >= lowerColor(1) & image(:,:,1) <= upperColor(1)) & ...
              (image(:,:,2) >= lowerColor(2) & image(:,:,2) <= upperColor(2)) & ...
              (image(:,:,3) >= lowerColor(3) & image(:,:,3) <= upperColor(3));

% morphological operations
binaryMask = bwareaopen(binaryMask, 500);  % remove small objects
binaryMask = imfill(binaryMask, 'holes');  % fill holes

% for testing purposes
%resultImage = bsxfun(@times, image, uint8(binaryMask));

labeledMask = bwlabel(binaryMask); % label components in binary mask

stats = regionprops(labeledMask, 'BoundingBox', 'PixelIdxList'); % get stats properties of image

croppedObjects = cell(1, numel(stats)); % cell array to store objects 

for i = 1:numel(stats)
    boundingBox = stats(i).BoundingBox; % get coordinates of the object's frame

    % adding padding
    paddingX = 100;  % padding along the width
    paddingY = 100;  % padding along the height
    expandedBoundingBox = [boundingBox(1) - paddingX, boundingBox(2) - paddingY, boundingBox(3) + 2 * paddingX, boundingBox(4) + 2 * paddingY];

    % crop the object from the original image
    cropped = imcrop(image, expandedBoundingBox);
    cropped = imresize(cropped, [256, 256]);
    croppedObjects{i} = cropped;
end


% testing purposes
%figure;
%subplot(1, 3, 1); imshow(image); title('Original Image');
%subplot(1, 3, 2); imshow(binaryMask); title('Binary Mask');
%subplot(1, 3, 3); imshow(resultImage); title('Result Image');
