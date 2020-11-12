bench = im2double(imread('photos/bench.jpg'));
p200 = im2double(imread('photos/P200.jpg'));
cat = im2double(imread('photos/cat.jpg'));
dog1 = im2double(imread('photos/dog1.jpg'));
dog2 = im2double(imread('photos/dog2.jpg'));
simba = im2double(imread('photos/simba.jpg'));

dimensions = [size(p200,1) size(p200,2) size(p200,3)];
load('masks.mat');
simba = imresize(simba, [dimensions(1) dimensions(2)]);
simba_mask = imresize(simba_mask, [dimensions(1) dimensions(2)]);


%bench and bench_mask resizing
small_bench = imresize(bench, 0.25);
bench_mask = imresize(bench_mask, 0.25);

bench = zeros(dimensions(1),dimensions(2),dimensions(3));
bench(1640:2251,571:1386,:)=small_bench-0.05;  %decrease image intensity

final_bench_mask = ones(dimensions(1),dimensions(2),1);
final_bench_mask(1640:2251,571:1386)=bench_mask;
final_bench_mask=1-final_bench_mask; %bench mask has its 1s and 0s reverted

%dog1 and dog1_mask resizing
small_dog1 = imresize(dog1, 0.2);
dog1_mask = imresize(dog1_mask, 0.2);

dog1 = zeros(dimensions(1),dimensions(2),dimensions(3));
dog1(1762:2251,1400:2052,:)=small_dog1-0.2;  %decrease image intensity

final_dog1_mask = zeros(dimensions(1),dimensions(2),1);
final_dog1_mask(1762:2251,1400:2052)=dog1_mask;

%dog2 and dog2_mask resizing
small_dog2 = imresize(dog2, 0.2);
dog2_mask = imresize(dog2_mask, 0.2);

dog2 = zeros(dimensions(1),dimensions(2),dimensions(3));
dog2(1812:2301,40:692,:)=small_dog2-0.1; %decrease image intensity

final_dog2_mask = zeros(dimensions(1),dimensions(2),1);
final_dog2_mask(1812:2301,40:692)=dog2_mask;

%cat and cat_mask resizing
small_cat = imresize(cat, 0.1);
cat_mask = imresize(cat_mask, 0.1);

cat = zeros(dimensions(1),dimensions(2),dimensions(3));
cat(2000:2244,700:1026,:)=small_cat-0.15;  %decrease image intensity

final_cat_mask = zeros(dimensions(1),dimensions(2),1);
final_cat_mask(2000:2244,700:1026)=cat_mask;

%simba and simba_mask resizing
small_simba = imresize(simba, 0.1);
simba_mask = imresize(simba_mask, 0.1);

simba = zeros(dimensions(1),dimensions(2),dimensions(3));
simba(1990:2234,950:1276,:)=small_simba; 

final_simba_mask = zeros(dimensions(1),dimensions(2),1);
final_simba_mask(1990:2234,950:1276)=simba_mask;


%pyramid creation
level = 5;

Lp200 = genPyr(p200,'lap',level); % the Laplacian pyramids
Lbench = genPyr(bench,'lap',level);
Ldog1 = genPyr(dog1, 'lap',level);
Ldog2 = genPyr(dog2, 'lap',level);
Lcat = genPyr(cat, 'lap',level);
Lsimba = genPyr(simba, 'lap',level);

%final masks for pyramid reconstruction
maskc = final_dog1_mask;
maskd = final_dog2_mask;
maske = final_cat_mask;
maskf = final_simba_mask;
maska = final_bench_mask -maske -maskf;
maskb = 1-maska-maskc-maskd-maske-maskf;

blurh = fspecial('gauss',30,15); % feather the border
maska = imfilter(maska,blurh,'replicate');
maskb = imfilter(maskb,blurh,'replicate');
maskc = imfilter(maskc,blurh,'replicate');
maskd = imfilter(maskd,blurh,'replicate');
maske = imfilter(maske,blurh,'replicate');
maskf = imfilter(maskf,blurh,'replicate');

Gmaska = genPyr(maska, 'gauss', level); %mask gaussian pyramids
Gmaskb = genPyr(maskb, 'gauss', level);
Gmaskc = genPyr(maskc, 'gauss', level);
Gmaskd = genPyr(maskd, 'gauss', level);
Gmaske = genPyr(maske, 'gauss', level);
Gmaskf = genPyr(maskf, 'gauss', level);

lapjoined = cell(1,level); % the blended pyramid

for p = 1:level
	[Mp Np ~] = size(Lp200{p});
	Gmaska{p} = imresize(Gmaska{p},[Mp Np]);
	Gmaskb{p} = imresize(Gmaskb{p},[Mp Np]);
    Gmaskc{p} = imresize(Gmaskc{p},[Mp Np]);
    Gmaskd{p} = imresize(Gmaskd{p},[Mp Np]);
    Gmaske{p} = imresize(Gmaske{p},[Mp Np]);
    Gmaskf{p} = imresize(Gmaskf{p},[Mp Np]);
	lapjoined{p} = Lbench{p}.*Gmaska{p} + Lp200{p}.*Gmaskb{p} + Ldog1{p}.*Gmaskc{p} + Ldog2{p}.*Gmaskd{p} + Lcat{p}.*Gmaske{p} +Lsimba{p}.*Gmaskf{p};
end

picture = pyrReconstruct(lapjoined);
figure,imshow(picture) % blend by pyramid