function analysis_protocol = analysis_protocol_from_metadata_file(metadata_file_name, settings_folder_path) 
    metadata = ReadMetadataFile(metadata_file_name) ;
    if isfield(metadata, 'screen_type') ,
        screen_type = metadata.screen_type ;
    else
        error('No analysis protocol specified in %s', metadata_file_name) ;
    end
    
    putative_analysis_protocol_1 = ['current_' screen_type] ;
    putative_analysis_protocol_path_1 = fullfile(settings_folder_path, putative_analysis_protocol_1) ;
    if exist(putative_analysis_protocol_path_1, 'dir') ,
        analysis_protocol = putative_analysis_protocol_1 ;
    else
        % If that didn't work, jut try the screen_type w/o 'current_' appended.
        putative_analysis_protocol_2 = screen_type ;
        putative_analysis_protocol_path_2 = fullfile(settings_folder_path, putative_analysis_protocol_2) ;
        if exist(putative_analysis_protocol_path_2, 'dir') ,
            analysis_protocol = putative_analysis_protocol_2 ;
        else
            error('Unable to find analysis protocol folder at path\n%s\nor at path\n%s', putative_analysis_protocol_path_1, putative_analysis_protocol_path_2) ;
        end
    end
end
