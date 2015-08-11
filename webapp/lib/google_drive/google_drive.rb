module GoogleDrive
  if Rails.env != 'test'

    class Api
      def initialize
        @client = Google::APIClient.new(application_name: "TCV drive", application_version: "1.0.0")
        @key = Google::APIClient::KeyUtils.load_from_pkcs12(APP_CONFIG[:google_drive][:path_p12], "notasecret")
        @client.authorization = Signet::OAuth2::Client.new(
                                  token_credential_uri:  APP_CONFIG[:google_drive][:token_credential_uri],
                                  audience:  APP_CONFIG[:google_drive][:audience],
                                  scope:  APP_CONFIG[:google_drive][:scope],
                                  issuer:  APP_CONFIG[:google_drive][:issuer],
                                  signing_key: @key,
                                  sub:  APP_CONFIG[:google_drive][:sub])
        @client.authorization.fetch_access_token!
        @drive = @client.discovered_api('drive', 'v2')
      end


      def get_url_csv(file_id)
        result = @client.execute(:api_method => @drive.files.get,
                                 :parameters => { 'fileId' => file_id })
        if result.status == 200
          return result.data['exportLinks']['text/csv']
        else
          raise "Obtaining file url failed : #{result.data['error']['message']}"
        end
      end

      def download_file(file_id)
        url = get_url_csv(file_id)
        raise "csv file not found in relation with file id : #{file_id}" if !url
        result = @client.execute(:uri => url)
        if result.status == 200
          return result.body
        else
          raise "Downloading file failed: #{result.data['error']['message']}"
        end
      end

      def insert_file(title, description, parent_id, mime_type, file_name)
        file = @drive.files.insert.request_schema.new({'title' => title,
                                                       'description' => description,
                                                       'mimeType' => mime_type})
        if parent_id
          file.parents = [{'id' => parent_id}]
        end
        media = Google::APIClient::UploadIO.new(file_name, mime_type)
        result = @client.execute(:api_method => @drive.files.insert,
                                 :body_object => file,
                                 :media => media,
                                 :parameters => { 'uploadType' => 'multipart',
                                                  'alt' => 'json'})
        if result.status == 200
          return result.data
        else
          raise "Uploading the file failed: #{result.data['error']['message']}"
        end
      end
    end

  else

    class Api
      def download_file(load_file)
        result = File.read(load_file)
      end
    end
  end
  
end

