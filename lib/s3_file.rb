module S3File

  # Legacy submission files were handled by S3 direct upload and we stored their
  # Amazon key in the "filepath" field. Here we check if it has a value, and if
  # so we use this to retrieve our secure url. If not, we use the path supplied by
  # the carrierwave uploader
  def url
    return file.url if Rails.env == "development"

    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    if filepath.present?
      bucket.objects[CGI::unescape(filepath)].url_for(:read, :expires => 15 * 60).to_s #15 minutes
    else
      bucket.objects[file.path].url_for(:read, :expires => 15 * 60).to_s #15 minutes
    end
  end

  def remove
    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    if filepath.present?
      bucket.objects[CGI::unescape(filepath)].delete
    else
      bucket.objects[file.path].delete
    end
  end

  private

  def strip_path
    if filepath.present?
      filepath.slice! "/gradecraft-#{Rails.env}/"
      write_attribute(:filepath, filepath)
      name = filepath.clone

      # 2015-01-06-11-16-33%2Fsome-file.jpg -> some-file.jpg
      # see s3 file structure created in /app/helpers/uploads_helper.rb
      name.slice!(/.*\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}%2F/)
      write_attribute(:filename, name)
    end
  end
end
