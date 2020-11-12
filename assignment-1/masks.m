bench = im2double(imread('photos/bench.jpg'));
cat = im2double(imread('photos/cat.jpg'));
dog1 = im2double(imread('photos/dog1.jpg'));
dog2 = im2double(imread('photos/dog2.jpg'));
simba = im2double(imread('photos/simba.jpg'));

%bench mask processing
%an edge detection method is used to create the bench mask.
%after edge detection on the bench image, additional processing is used to
%optimize the mask.

[~, threshold] = edge(bench(:,:,1));
fudgefactor = 0.5;
bw = edge(bench(:,:,1), threshold*fudgefactor);

se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(bw,[se90 se0]);
BWdfill = imfill(BWsdil,'holes');
seD = strel('diamond',1);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);

BWfinal(:,1:240,:)=1;      %manual masking out zones
BWfinal(:,3050:3264,:)=1;
BWfinal(1:950,:,:)=1;
BWfinal(950:1650,240:530,:)=1;
bench_mask = BWfinal;

%the animals' masks are extracted using drawassisted matlab func.
figure, imshow(dog1);
roi_dog1 = drawassisted;
dog1_mask = createMask(roi_dog1);

figure, imshow(dog2);
roi_dog2 = drawassisted;
dog2_mask = createMask(roi_dog2);

figure, imshow(cat);
roi_cat = drawassisted;
cat_mask = createMask(roi_cat);

figure, imshow(simba);
roi_simba = drawassisted;
simba_mask = createMask(roi_simba);