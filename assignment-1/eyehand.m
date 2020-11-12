eye = im2double(imread('photos/woman.png'));
hand = im2double(imread('photos/hand.png')); % size(imga) = size(imgb)
hand = imresize(hand,[size(eye,1) size(eye,2)]);

[M N ~] = size(eye);
level = 5;

lap1 = genPyr(eye,'lap',level); % the Laplacian pyramid
lap2 = genPyr(hand,'lap',level);

maska = createMask(roi);
maskb = 1-maska;

blurh = fspecial('gauss',30,15); % feather the border
maska = imfilter(maska,blurh,'replicate');
maskb = imfilter(maskb,blurh,'replicate');

Gmaska = genPyr(maska, 'gauss', level); %mask gaussian pyramids
Gmaskb = genPyr(maskb, 'gauss', level);

lapjoined = cell(1,level); % the blended pyramid

for p = 1:level
	[Mp Np ~] = size(lap1{p});
	Gmaska{p} = imresize(Gmaska{p},[Mp Np]);
	Gmaskb{p} = imresize(Gmaskb{p},[Mp Np]);
	lapjoined{p} = lap1{p}.*Gmaska{p} + lap2{p}.*Gmaskb{p};
end

picture = pyrReconstruct(lapjoined);
figure,imshow(picture) % blend by pyramid