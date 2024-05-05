testImage = imread('Images\pineapple\IMG_8022.HEIC.jpeg');
%imshow(testImage);

testingImageVector = double(testImage(:));

testoutput = net(testingImageVector);
[confidence, predictedClass] = max(testoutput);

disp('Output Values:');
disp(testoutput);

disp(['Predicted Class: ' num2str(predictedClass)]);
disp(['Confidence: ' num2str(confidence)]);