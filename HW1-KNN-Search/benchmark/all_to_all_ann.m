function all_to_all_ann(input_file)
    % Computes k-nearest neighbors for data in an HDF5 file and updates the file with results.
    % The matrices in the HDF5 file are assumed to be in row-major order.
    %
    % Args:
    %   input_file (string): Path to the HDF5 file to be updated.

    % Step 1: Load the train data from the input HDF5 file (transpose to column-major for MATLAB)
    disp(['Reading train data from: ', input_file]);
    train = single(h5read(input_file, '/train')');  % Transpose to column-major

    % Step 2: Determine the number of neighbors (k) from the initial /distances matrix
    disp('Determining k from the /distances matrix...');
    initial_distances = h5read(input_file, '/distances')';  % Transpose to column-major
    k = size(initial_distances, 2);  % Number of columns gives k
    disp(['Number of neighbors (k): ', num2str(k)]);
    fprintf('Train size: %d x %d\n', size(train, 1), size(train, 2));

    % Step 3: Compute k-Nearest Neighbors
    disp('Computing k-nearest neighbors...');
    [D, IDX] = knnsearch(train, train, 'K', k);

    % Step 4: Write updated distances and neighbors datasets
    disp(['Overwriting distances and neighbors in: ', input_file]);

    % Write distances (as float, transposed back to row-major) to the same file
    try
        h5create(input_file, '/distances', size(D'), 'Datatype', 'single');  % Row-major
    catch
        % If dataset already exists, suppress the error
        disp('Overwriting existing /distances dataset.');
    end
    h5write(input_file, '/distances', single(D'));  % Transpose back to row-major

    % Write neighbors (as int32, transposed back to row-major) to the same file
    try
        h5create(input_file, '/neighbors', size(IDX'), 'Datatype', 'int32');  % Row-major
    catch
        % If dataset already exists, suppress the error
        disp('Overwriting existing /neighbors dataset.');
    end
    h5write(input_file, '/neighbors', IDX');  % Transpose back to row-major

    disp(['KNN results updated in: ', input_file]);
end
