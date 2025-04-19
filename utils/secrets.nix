_: let
  inherit ((import ./concat-paths.nix {})) concatPaths;
  inherit ((import ./list-to-nested-attrset.nix {})) listToNestedAttrs;
  inherit ((import ./recursive-merge.nix {})) recursiveMerge;
  inherit (builtins)
    readDir
    attrNames
    removeAttrs
    typeOf
    foldl'
    filter
    match
    readFile
    pathExists
    listToAttrs
    head
    map
    stringLength
    substring
    split;

  # Taken from Nixpkgs's lib
  filterAttrs = pred: set: removeAttrs set (filter (name: !pred name set.${name}) (attrNames set));

  # Merge a list of attrs into a single attr
  mergeAttrs = list: foldl' (acc: item: acc // item) {} list;

  getAllSecrets = {host, relPathList ? [], accConfig ? {}}: let
    # Add the current directory's config.nix to the accumulated config variable (accConfig')
    fullPath = concatPaths ([../secrets/.] ++ relPathList);
    newConfigFilepath = concatPaths [fullPath "config.nix"];
    newConfig = if pathExists newConfigFilepath then (import newConfigFilepath) { inherit host; } else {};
    accConfig' = accConfig // newConfig;

    # List of all the files in the current directory
    files = attrNames (filterAttrs (_name: type: type == "regular") (readDir fullPath));

    # Get all age files in the current directory
    ageFiles = (filter (file: (match ".+\\.age" file) != null) files) ++
      (map (fileName: substring 0 ((stringLength fileName) - 5) fileName) (filter (file: (match ".+\\.age-temp" file) != null) files));
    # ageFiles = filter (file: (match ".+\\.age" file) != null) files;

    # List of all the directories in the current directory
    directories = attrNames (filterAttrs (_name: type: type == "directory") (readDir fullPath));

    # List of the secrets in the current directory
    secrets = listToAttrs (map (fileName: rec {
      name = concatPaths (relPathList ++ [fileName]);
      value = accConfig' // {
        relFilePath = name;
        filePath = concatPaths [fullPath fileName];
      };
    }) ageFiles);

    # Get all the other files in the current directory and their contents
    otherFiles = filter (file: (match ".+\\.(age|nix)" file) == null) files;
    otherFilesWithContent = listToAttrs (map (fileName: rec {
      name = concatPaths (relPathList ++ [fileName]);
      value = rec {
        relFilePath = name;
        filePath = concatPaths [fullPath fileName];
        content = readFile filePath;
      };
    }) otherFiles);

    # Recursively evaluate directories
    evaluatedDirectories = map (dirName: 
      getAllSecrets {
        inherit host;
        relPathList = relPathList ++ [dirName];
        accConfig = accConfig';
      }
    ) directories;
    directoriesSecrets = map (dir: dir.secrets) evaluatedDirectories;
    directoriesOther = map (dir: dir.other) evaluatedDirectories;
  in {
    secrets = secrets // (mergeAttrs directoriesSecrets);
    other = otherFilesWithContent // (mergeAttrs directoriesOther);
  };

  # Split a string by "/"
  pathSplitter = name: filter (val: typeOf val == "string") (split "/" name);
  # This function removes all of the file extensions of a file.
  # Assumes the directories don't have "." in them.
  removeFileExtension = filePath: head (split "\\." filePath);

  # Transform flat paths to nested structure
  transformToNestedPaths = flatObj:
    foldl' 
      (acc: name:
        let
          pathList = pathSplitter (removeFileExtension name);
          value = flatObj.${name};
        in
          recursiveMerge [
            acc
            (listToNestedAttrs pathList value)
          ]
      ) {} (attrNames flatObj);
in {
  inherit
    transformToNestedPaths
    getAllSecrets;
}
