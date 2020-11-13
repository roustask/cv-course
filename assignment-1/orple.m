close all
clear
imga = im2double(imread('photos/apple.jpg'));
imgb = im2double(imread('photos/orange.jpg')); % size(imga) = size(imgb)
imga = imresize(imga,[size(imgb,1) size(imgb,2)]);
[M N ~] = size(imga);
v = 230;
level = 5;
limga = genPyr(imga,'lap',level); % the Laplacian pyramid
limgb = genPyr(imgb,'lap',level);
maska = zeros(size(imga));
maska(:,1:v,:) = 1;
maskb = 1-maska;
blurh = fspecial('gauss',30,15); % feather the border
maska = imfilter(maska,blurh,'replicate');
maskb = imfilter(maskb,blurh,'replicate');
Gmaska = genPyr(maska, 'gauss', level); %mask gaussian pyramids
Gmaskb = genPyr(maskb, 'gauss', level);

limgo = cell(1,level); % the blended pyramid
for p = 1:level
	[Mp Np ~] = size(limga{p});
	Gmaska{p} = imresize(Gmaska{p},[Mp Np]);
	Gmaskb{p} = imresize(Gmaskb{p},[Mp Np]);
	limgo{p} = limga{p}.*Gmaska{p} + limgb{p}.*Gmaskb{p};
end
imgo = pyrReconstruct(limgo);
figure,imshow(imgo) % blend by pyramid
