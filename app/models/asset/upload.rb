#
# Asset::Upload
#
# Code that handles the creation of new assets from uploaded data.
#

require 'fileutils'

module Asset::Upload
  extend ActiveSupport::Concern

  included do
    validate :validate_upload_data
    before_validation :process_attachment
    after_update :finalize_attachment  #  \  both are
    after_create :finalize_attachment  #  /  needed

    attr_reader :uploaded_data
  end

  module ClassMethods
    ZIP_MIME_TYPES = %w[application/zip multipart/zip application/zip-compressed].freeze

    def create_from_param_with_zip_extraction(param)
      return [] if param.empty?
      begin
        make_from_zip(param).first
      rescue Zip::ZipError
        asset = create_from_params(uploaded_data: param)
        [asset]
      end
    end

    def make_from_zip(file)
      file = ensure_temp_file(file)
      zipfile = Zip::ZipFile.new(file.path)
      assets = []
      # array of filenames for which processing failed
      failures = []
      # to preserve filenames without too much hacks we work in a
      # seperate directory.
      tmp_dir = File.join(Rails.root, 'tmp', "unzip_#{Time.now.to_i}")
      Dir.mkdir(tmp_dir)
      zipfile.each do |entry|
        begin
          next if entry.directory?
          tmp_file = File.join(tmp_dir, entry.name)
          FileUtils.mkdir_p(File.dirname(tmp_file))
          zipfile.extract(entry, tmp_file) unless File.exist?(tmp_file)
          asset = create_from_params uploaded_data: FileData.new(tmp_file)
          assets << asset if asset
        rescue => exc
          logger.fatal("Error while extracting asset #{tmp_file} from ZIP Archive: #{exc.message}")
          exc.backtrace.each do |bt|
            logger.fatal(bt)
          end
          begin
            failures << entry.name
          rescue
            nil
          end
        end
      end
      # tidy up
      FileUtils.rm_r(tmp_dir) if tmp_dir && File.exist?(tmp_dir)
      [assets, failures.compact]
    end

    protected

    def ensure_temp_file(file)
      if file.is_a?(ActionController::UploadedStringIO)
        ext = File.extname(file.original_filename).sub(/^\./, '')
        base = File.basename(file.original_filename, ext)
        temp_file = Tempfile.new([base, ext])

        temp_file.write file.read
        file = temp_file
        temp_file.close
      end
      file
    end
  end

  def validate_upload_data
    if new_record?
      unless uploaded_data_changed?
        errors.add(:uploaded_data, I18n.t('errors.messages.empty'))
      end
    end
  end

  #
  # html forms for assets have a field called 'uploaded_data'. This setter
  # will grab the uploaded file from that field. There is not actually a
  # column in the db called 'uploaded_data'. the actual work is done in
  # finalize_attachment
  #
  def uploaded_data=(file_data)
    attribute_will_change!('uploaded_data') if file_data != @uploaded_data
    @uploaded_data = file_data
  end

  def uploaded_data_changed?
    changed.include? 'uploaded_data'
  end

  #
  # called before validation in order to create @temp_file from the data and
  # to extract meta-data. @temp_file is turned into permanent storage later on
  # in finalize_attachment().
  #
  def process_attachment
    if @uploaded_data
      # temporarily capture old filenames
      @old_files = all_filenames || []

      # create @temp_file from uploaded file
      self.content_type  = Asset.mime_type_from_data(@uploaded_data)
      self.filename      = @uploaded_data.original_filename
      filename_will_change! # just in case nothing is different, force dirty.
      @temp_file = Media::TempFile.new(@uploaded_data, content_type)
      @uploaded_data = nil

      alter_asset_class(content_type)
      extract_metadata(@temp_file)
    end
    true
  end

  #
  # copies the temporary files to permanent storage.
  # called after creation and every update.
  #
  def finalize_attachment
    if @old_files
      remove_files(*@old_files)
      @old_files.clear
      @old_files = nil
    end
    if @temp_file
      save_to_storage(@temp_file.path)
      @temp_file.clear
      @temp_file = nil
      create_thumbnail_records
    end
    true
  end

  private

  # if the asset class has changed, then we change the type column for this
  # model. the next time this object is loaded, it will be a different class.
  def alter_asset_class(content_type)
    asset_class = Asset.class_for_mime_type(content_type)
    if self.class != asset_class
      thumbnails.clear
      klass = Media::MimeType.asset_class_from_mime_type(content_type)
      self.type = klass.constantize.sti_name
      self.thumbdefs = asset_class.class_thumbdefs
    end
  end

  def extract_metadata(file)
    self.size = File.size(file.path)
    if Media.has_dimensions?(content_type)
      self.width, self.height = Media.dimensions(file.path)
    end
  end
end
