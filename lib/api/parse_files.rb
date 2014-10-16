module API
  class ParseFiles < Grape::API
    helpers do
      def filename_with_format(params)
        filename = params[:format].nil? ? 
                        params[:file_name] : 
                        params[:file_name] + "." + params[:format]  
      end
    end
    
    resource :files do
      post ':file_name' do
        parse_file = ParseFile.new
        
        filename = filename_with_format(params)
        tempf = Tempfile.new("fileupload")
        tempf.binmode
        tempf.write(request.body.read)
        parse_file.pfile = ActionDispatch::Http::UploadedFile.new( 
                tempfile: tempf, 
                filename: filename, 
                original_filename: filename
            )
        tempf.close
        tempf.unlink
 
        parse_file.save
        header "Location", parse_file_url(parse_file)
        content_type "application/json"
        return parse_file
      end

      delete ':file_name' do
        parse_file = ParseFile.find_by(pfile: filename_with_format(params))
        parse_file.destroy
        nil
      end
    end

  end
end