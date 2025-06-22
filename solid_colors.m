%% tranformando os blocos da imagem original em blocos de cor solida

clc; clear; close all;
%% imagem a ser transformada
target_img = imread('img/flores.jpg');  
target_img = im2double(target_img);
[rows, cols, ~] = size(target_img);

tile_size = 10; %% ?
tile_rows = floor(rows / tile_size);
tile_cols = floor(cols / tile_size);
target_colors = zeros(tile_rows, tile_cols, 3);

%% media de cor para cada bloco da imagem original
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
    end
end

%% imagem recontruida com a cor média de cada bloco
solid_colors_img = zeros(tile_rows * tile_size, tile_cols * tile_size, 3);

for y = 1:tile_rows
    for x = 1:tile_cols
        color = squeeze(target_colors(y, x, :));
        row_start = (y-1)*tile_size + 1;
        col_start = (x-1)*tile_size + 1;
        solid_colors_img(row_start: y*tile_size, ... rows
            col_start: x*tile_size, ... cols
            :) = repmat(reshape(color, 1,1,3), tile_size, tile_size); % preencher todo bloco com a cor solida
    end
end

imwrite(solid_colors_img, 'img/original_solid_colors.jpg');