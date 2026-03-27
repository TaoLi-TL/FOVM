
input_folder = 'input';
output_folder = 'output';
tic;

supported_formats = {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff', '.gif'};

all_files = dir(input_folder);
image_files = [];

for i = 1:length(all_files)
    if ~all_files(i).isdir
        [~, ~, ext] = fileparts(all_files(i).name);
        if any(strcmpi(ext, supported_formats))
            image_files = [image_files; all_files(i)];
        end
    end
end


for i = 1:length(image_files)

    filename = image_files(i).name;
    filepath = fullfile(input_folder, filename);

    I = im2double(imread(filepath));


    [O,~] = glow_removal(I);


    eps=0.001;
    Ihsv = rgb2hsv(O);
    H = Ihsv(:, :, 1);
    S = Ihsv(:, :, 2);
    V = Ihsv(:, :, 3);
    gray=rgb2gray(O);
    B=guidedfilter(gray,V,7,eps);
    R_channel = O(:,:,1);
    G_channel = O(:,:,2);
    B_channel = O(:,:,3);


    [L_R, R_R] = fractional_poisson_dehazing(R_channel,B);
    [L_G, R_G] = fractional_poisson_dehazing(G_channel,B);
    [L_B, R_B] = fractional_poisson_dehazing(B_channel,B);

    I_R = cat(3, R_R, R_G, R_B);
    I_L = cat(3, L_R, L_G, L_B);

    I_R = min(max(I_R, 0),1);
    I_L = min(max(I_L, 0),1);



    R_enhanced = R_enhancement(I_R);
    L_enhanced = L_enhancement(I_L);

    Final = L_enhanced.*R_enhanced;
    [~, name, ext] = fileparts(filename);
    output_filename = fullfile(output_folder, [name '_processed.png']);
    imwrite(Final, output_filename);

    fprintf('已处理并保存: %s\n', filename);


end
toc;