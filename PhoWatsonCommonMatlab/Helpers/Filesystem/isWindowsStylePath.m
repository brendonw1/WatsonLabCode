function TF = isWindowsStylePath(path)
%isWindowsStylePath Returns true if it's a valid Windows file path. Otherwise it's expected to be Unix formatted.
    % If it contains any forward slashes at all, it isn't a valid windows file path.
    TF = ~contains(path, '/');
end
