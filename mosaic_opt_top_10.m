%% Simpler Photomosaic  -> downsampling of the original image
%% https://en.wikipedia.org/wiki/Photographic_mosaic
%% each tile of the original image is reduced to a single color
%% each library image is reduced to a single color
%% choses the 10 closest images, if it's not used by its neighbors and matchs with the tile

clc; clear; close all;

tic; %% tempo

%% imagem a ser transformada
target_img = imread('img/flores.jpg');  
target_img = im2double(target_img);
[rows, cols, ~] = size(target_img);

tile_size = 10; %% tamanho dos tiles
tile_rows = floor(rows / tile_size);
tile_cols = floor(cols / tile_size);
target_colors = zeros(tile_rows, tile_cols, 3);

%% conjunto de imagens e respectivas cores
img_files = imageDatastore('flowers_200', FileExtensions={'.jpg'}, IncludeSubfolders = false);
num_imgs = numel(img_files.Files);
image_set = readall(img_files);
imgs_colors = zeros(num_imgs, 3);

for i = 1:num_imgs
    img = image_set{i};
    img = im2double(img);
    img = imresize(img, [tile_size, tile_size]); % Redimensionar para o tamanho do bloco
    image_set{i} = img;

    %% media dos canais da imagem
    r = mean(img(:,:,1),'all');
    g = mean(img(:,:,2),'all');
    b = mean(img(:,:,3),'all');

    imgs_colors(i, :) = squeeze([r,g,b]); 
end

%% percorrer cada bloco
mosaic_img = zeros(size(target_img));
n_vizinhos = 2; % numero de tiles de distancia
match_index = zeros(tile_rows, tile_cols);

for y = 1:tile_rows
    for x = 1:tile_cols
        row_start = (y-1)*tile_size+1;
        col_start = (x-1)*tile_size+1;
        tile = target_img(row_start : y*tile_size, ... row
            col_start: x*tile_size, ... column
            :);
            
        %% media dos canais do bloco
        r = mean(tile(:,:,1),'all');
        g = mean(tile(:,:,2),'all');
        b = mean(tile(:,:,3),'all');

        target_colors(y, x, :) = squeeze([r,g,b]); 
        
        %% cores medias das imagens da biblioteca
        tile_color = squeeze(target_colors(y, x, :))'; % transposto
        diff = imgs_colors - tile_color;
        distances = sqrt(sum(diff.^2, 2));  
        [sorted_dist, sorted_id] = sort(distances);

        %% pega uma imagem aleatoria entre as 10 mais proximas, ignorando a já usada na vizinhança 5x5
        top_closest = sorted_id(1:10);
        closest_id = -1;

        row_min = max(y-n_vizinhos,1);
        row_max = min(y+n_vizinhos, tile_rows);
        col_min = max(x-n_vizinhos,1);
        col_max = min(x+n_vizinhos, tile_cols);
        
        used_ids = unique(match_index(max(y-n_vizinhos,1):min(y+n_vizinhos,tile_rows), ...
                    max(x-n_vizinhos,1):min(x+n_vizinhos,tile_cols)));
        top_closest = top_closest(~ismember(top_closest,used_ids));

        if isempty(top_closest)
            closest_id = sorted_id(1);
        else
            closest_id = top_closest(randi(length(top_closest)));
        end

        %% verifica se ja foi usado vizinhança 5x5
        
        match_index(y,x) = closest_id;

        %% substitui o bloco
        lib_img = image_set{closest_id};
        row_start = (y-1)*tile_size + 1;
        col_start = (x-1)*tile_size + 1;
        mosaic_img(row_start: y*tile_size, ... rows
            col_start: x*tile_size, ... cols
            :) = lib_img;

    end
end

%% plot 
imwrite(mosaic_img, 'img/photomosaic_opt_result.jpg');

figure;
subplot(1, 2, 1); imshow(target_img); title('Original Image')
subplot(1, 2, 2); imshow(mosaic_img); title('Photomosaic');

%% tempo
elapsed_time = toc;
fprintf('Tempo de execução: %.2f segundos\n', elapsed_time);

%% diferença cores
dif_colors = double(target_img) - double(mosaic_img);
similarity = mean(abs(dif_colors(:)));
fprintf('Diferença média de cor: %.2f\n', similarity);

%% Qtd de tiles unicos usados
unique_tiles = unique(match_index(:));
fprintf('Quantidade de tiles unicos: %d', numel(unique_tiles));